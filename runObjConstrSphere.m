function [x, f, eflag, outpt] = runObjConstrSphere(x0, sphere, opts, flagConstr)

if nargin == 1 % No options supplied
    opts = [];
end

xLast = []; % Last place powerFun was called
myf = []; % Use for objective at xLast
myc = []; % Use for nonlinear inequality constraint
myceq = []; % Use for nonlinear equality constraint

fun = @objfun; % the objective function, nested below
cfun = @constr; % the constraint function, nested below

lb = [0; 0];
ub = [1e10; 1e10];

% Call fmincon
if flagConstr   % if motion is constrained
    [x,f,eflag,outpt] = fmincon(@(x)-fun(x,sphere),x0,[],[],[],[],lb,ub,@(x)cfun(x,sphere),opts);
else            % unconstrained motion, no c and ceq, only lb and ub
    [x,f,eflag,outpt] = fmincon(@(x)-fun(x,sphere),x0,[],[],[],[],lb,ub,[],opts);
end

    function y = objfun(x,sphere)
        if ~isequal(x,xLast) % Check if computation is necessary
            [myf,myc,myceq] = powerFunSphere(x,sphere);
            xLast = x;
        end
        % Now compute objective function
        y = myf;
    end

    function [c,ceq] = constr(x,sphere)
        if ~isequal(x,xLast) % Check if computation is necessary
            [myf,myc,myceq] = powerFunSphere(x,sphere);
            xLast = x;
        end
        % Now compute constraint functions
        c = myc; % In this case, the computation is trivial
        ceq = myceq;
    end

end