function lookUpTable = optimalPTO(radii, siteOpts)

disp('PTO optimisation srarted ...')
% Calculation of optimal PTO parameters
% motion is constrained to +/- 3 m
% optimal PTO for each frequency
% optimal PTO for each buoy size

radiusUnique = unique(radii);

% Detect what buoy size is in the middle
if length(radiusUnique) == 1
    aMid = radiusUnique;
else
    idx = floor(length(radiusUnique)/2 + 1);
    aMid = radiusUnique(idx);
end

numApprox = 4;
numFreq = length(siteOpts.waveFreqs);
g	= 9.80665;	% m/sec^2
rho	= 1025;     % kg/m^3, density of the water
Aw	= 1;
opts = optimoptions(@fmincon, 'Algorithm','interior-point', 'Display', 'off');

wave.waterDensity = rho;
wave.angle = 0;

subDepthT = siteOpts.submergenceDepth;

% Calculation of the tether length depending on the water depth
tetherZ = (siteOpts.waterDepth - subDepthT - aMid);  % z-projection of the tether, from the sphere centre
tetherL = tetherZ*sqrt(3);              % tether length, from the sphere centre (instead of (h-f)/cos(alpha))
tetherXY = tetherZ*sqrt(2);             % x-y-projection of the sphere, instead of tetherL*sin(alpha) - it is also a radius of the circle for the hexagon

for count_a = 1:length(radiusUnique)
    
    a = radiusUnique(count_a);	% radius
    V = 4/3*pi*a^3;             % volume

    mass	= 0.7*V*rho;        % mass
    Ft      = (rho*g*V - mass*g);
    
    % Structure of the isolated sphere
    sphere.radius           = a;
    sphere.massMatrix       = eye(3)*mass;
    sphere.tetherPretention = Ft;
    sphere.number           = 1;
    sphere.sphereCoordinate = [0; 0; -(subDepthT + a)];
    sphere.oceanDepth       = siteOpts.waterDepth;
    sphere.submergenceDepth = subDepthT + a;
    sphere.waveAngle        = wave.angle;
    sphere.tetherAngle      = atan(tetherXY/(siteOpts.waterDepth - subDepthT - a));
    
    fname = ['radius', num2str(a*10)];
    
    lookUpTable.(fname).mass        = mass;
    lookUpTable.(fname).volume      = V;
    lookUpTable.(fname).tetherAngle = sphere.tetherAngle;
    lookUpTable.(fname).power       = zeros(1, numFreq);
    lookUpTable.(fname).kPTO        = zeros(1, numFreq);
    lookUpTable.(fname).dPTO        = zeros(1, numFreq);
    lookUpTable.(fname).wavePower   = zeros(1, numFreq);
    lookUpTable.(fname).waveFreqs   = zeros(1, numFreq);
    
    for count_w = 1:numFreq
        
        w = siteOpts.waveFreqs(count_w);
        
        K = w^2/g;
        
        [A, B, X] = arraySubmergedSphereParfor(sphere, wave, w, K, numApprox, 1);

        sphere.addedMass = A;
        sphere.damping = B;
        sphere.excitationForce = X;
        sphere.waveFrequency = w;
        sphere.waveNumber = K;
        
        %% Optimisation (constrained)
        % Initial values of PTO's k and d
        alpha = sphere.tetherAngle;
        k_in_1 = 2*(mass + A(1,1))*w^2/(3*sin(alpha)^2);
        d_in_1 = 2*B(1,1)/(3*sin(alpha)^2);
        
        k_in_3 = (mass + A(3,3))*w^2/(3*cos(alpha)^2);
        d_in_3 = B(3,3)/(3*cos(alpha)^2);
        
        x0(1,:) = [k_in_1, d_in_1];
        x0(2,:) = [k_in_3, d_in_3];

        % Detect optimal PTO parameters
        for count_opt = 1:2
            [par(count_opt,:), fval(count_opt,:)] = runObjConstrSphere(x0(count_opt,:), sphere, opts, 1);
        end
        
        [~, idx] = min(fval);
        
        lookUpTable.(fname).kPTO(count_w)        = par(idx, 1);        
        lookUpTable.(fname).dPTO(count_w)        = par(idx, 2);
        lookUpTable.(fname).power(count_w)       = -fval(idx);
        lookUpTable.(fname).wavePower(count_w)   = rho*g^2/(4*w)*Aw^2;
        lookUpTable.(fname).waveFreqs(count_w)   = w;
        
    end
end

disp('PTO optimisation finished ...')
save ptoParameters lookUpTable