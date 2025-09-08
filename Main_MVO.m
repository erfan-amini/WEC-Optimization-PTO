clear all
clc;
close all;
%% Input Data
lb_id          = 1;
ub_id          = 5;  
Opt.SN         = 25;  %25
Opt.Maxiter    = 10000; %10000
Opt.WaveModel  = 4;  %1:Perth 4:Sydney
%% Initial Values
warning('off','all');
warning ;
% rng('shuffle')% creating random number generator based on the current time
% Seedrng= randi([1,100000],1,100000);
% Seedrng(id)
% rng(Seedrng(id))
%  clear Seedrng

Opt.Buoy_Number           = 1;
Opt.Position              = [100 ;100];
Opt.Max_kPTO              = 550000;
Opt.Min_kPTO              = 1;
Opt.Max_dPTO              = 400000;
Opt.Min_dPTO              = 50000;
Opt.Nvar                  = Opt.Buoy_Number*300;      % number of objective variables/problem dimension

array.kPTO                = rand([Opt.Buoy_Number,3,50])*Opt.Max_kPTO;
array.dPTO                = rand([Opt.Buoy_Number,3,50])*Opt.Max_dPTO;
array.dPTO                = max(array.dPTO,Opt.Min_dPTO);

array.number                 = Opt.Buoy_Number;
array.radius                 = 5* ones(1,array.number);
array.sphereCoordinate       = zeros(3,array.number);
array.sphereCoordinate(1:2,:)= Opt.Position;
array.qW                     = [];
array.ParrayW                = [];
array.ParrayBuoyW            = [];
%% fminsearchbnd parameters
Opt.LB                    = [repmat(Opt.Min_kPTO,1,150),repmat(Opt.Min_dPTO,1,150)];
Opt.UB                    = [repmat(Opt.Max_kPTO,1,150),repmat(Opt.Max_dPTO,1,150)];
%% WAVE CLIMATE
% read netcdf file into matlab to get the probablity diagram of sea states
%%%%%%%%%%%%%
% Information on the netcdf file, put ncdisp(fname)
%%%%%%%%%%%%%

location = Opt.WaveModel;

switch location
    case 1  % Perth
        fname = '01Perth.nc';
        siteName = 'Perth';
        disp('the results are related to the Perth wave model')
    case 2  % Adelaide
        fname = '02Adelaide.nc';
        siteName = 'Adelaide';
        disp('the results are related to the Adelaide wave model')
    case 3  % Tasmania
        fname = '03Tasmania.nc';
        siteName = 'Tasmania';
        disp('the results are related to the Tasmania wave model')
    case 4  % Sydney
        fname = '04Sydney.nc';
        siteName = 'Sydney';
        disp('the results are related to the Sydney wave model')
        
        
end

time    = ncread(fname,'time');
hs      = ncread(fname,'hs');
fp      = ncread(fname,'fp');
tm0m1   = ncread(fname,'tm0m1');
dirWave = ncread(fname,'dir');

n1 = length(find(time==-32767));
n2 = length(find(hs==-32767));
n3 = length(find(fp==-32767));
n4 = length(find(tm0m1==-32767));
n5 = length(find(dirWave==-32767));

nMax = max([n1, n2, n3, n4, n5]);

time(1:nMax)    = [];
hs(1:nMax)      = [];
fp(1:nMax)      = [];
tm0m1(1:nMax)   = [];
dirWave(1:nMax) = [];

dirWave(dirWave == 360) = 0;

%% 4D Histogram (wave height, wave period, wave direction)
xbins_hs = 0.5:1:[ceil(max(hs))+0.5];
xbins_tp = round(1/max(fp)):1:round(1/min(fp));
xbins_wa = 0:15:360;

[counts, edges, mid, loc] = histcn([hs 1./fp dirWave], xbins_hs, xbins_tp, xbins_wa);

%% Detect significant wave directions
N_hist_wa = squeeze(sum(sum(counts, 1), 2));

[N_hist_wa_sort, I_wa_sort] = sort(N_hist_wa, 'descend');

n_wa = 0;
ii = 0;
while n_wa < 0.90
    ii = ii + 1;
    n_wa = n_wa + N_hist_wa_sort(ii)/sum(N_hist_wa_sort);
end

I_wa = sort(I_wa_sort(1:ii));

%% Detect significant wave heights
N_hist_hs = squeeze(sum(sum(counts, 3), 2));

[N_hist_hs_sort, I_hs_sort] = sort(N_hist_hs, 'descend');

n_hs = 0;
ii = 0;
while n_hs < 0.90
    ii = ii + 1;
    n_hs = n_hs + N_hist_hs_sort(ii)/sum(N_hist_hs_sort);
end

I_hs = sort(I_hs_sort(1:ii));

%% Detect significant peak wave periods
N_hist_tp = squeeze(sum(sum(counts, 1), 3));

[N_hist_tp_sort, I_tp_sort] = sort(N_hist_tp, 'descend');

n_tp = 0;
ii = 0;
while n_tp < 0.90
    ii = ii + 1;
    n_tp = n_tp + N_hist_tp_sort(ii)/sum(N_hist_tp_sort);
end

I_tp = sort(I_tp_sort(1:ii));

%% Data reduction
N_hist          = counts(I_hs, I_tp, I_wa);
Hs_hist         = mid{1}(I_hs);
Tp_hist         = mid{2}(I_tp);
waveAngle_hist	= mid{3}(I_wa);

%% Define the parameters you want to run the model
siteOpts.waterDepth         = 30;  % Water depth
siteOpts.submergenceDepth   = 3;   % Submergence depth of the buoy (from the water level to the top of the buoy)
siteOpts.waveFreqs          = linspace(0.2, 2, 50);
siteOpts.location.siteName  = siteName;
siteOpts.location.Hs        = Hs_hist;
siteOpts.location.Tp        = Tp_hist;
siteOpts.location.waveAngle = waveAngle_hist*pi/180;
siteOpts.location.N_hist    = N_hist;

array.sphereCoordinate(3,:) = -(siteOpts.submergenceDepth + array.radius);

%% -------------Call Optimisation method -------------

parfor id = lb_id:ub_id
    MVO(array,siteOpts,Opt,id,siteName);
end

disp('Done!')