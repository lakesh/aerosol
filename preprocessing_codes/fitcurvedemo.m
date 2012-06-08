function [estimates, model] = fitcurvedemo(xdata, ydata)
% Call fminsearch with a random starting point.
start_point(1) = 100;
start_point(2) = 1;

model = @expfun;
options = optimset('TolFun',1e-8,'TolX',1e-8);

[estimates val] = fminsearch(model, start_point,options);
% expfun accepts curve parameters as inputs, and outputs sse,
% the sum of squares error for A*exp(-lambda*xdata)-ydata,
% and the FittedCurve. FMINSEARCH only needs sse, but we want
% to plot the FittedCurve at the end.
    function [sse, FittedCurve] = expfun(params)
        range = params(1);
        sill = params(2);
        FittedCurve = sill*(1- exp(-3 * xdata/range));
        ErrorVector = FittedCurve - ydata;
        sse = sum(ErrorVector .^ 2);
    end
end
