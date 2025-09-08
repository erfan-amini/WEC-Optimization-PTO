function [kPTO,dPTO] = Initialize_firstpop(Opt)

   
%    kPTO=unifrnd(Min_kPTO,Max_kPTO,[1 nVar/2]);
%    dPTO=unifrnd(Min_dPTO,Max_dPTO,[1 nVar/2]);
kPTO                = rand([1,3,50])*Opt.Max_kPTO;
dPTO                = rand([1,3,50])*Opt.Max_dPTO;
dPTO                = max(dPTO,Opt.Min_dPTO);
  
end