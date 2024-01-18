function [regLine, rsq] = calculateLinearRegression(x, y, polyTerm)
% Performs a basic linear regression and calculates the line of best fit,
% and the r^2 term based on https://www.mathworks.com/help/matlab/data_analysis/linear-regression.html

% Get the coefficients for the line of best fit

p = polyfit(x, y, polyTerm);

% Get the line of best fit
regLine = polyval(p, x);

% Calculate the R^2
yResid = y - regLine;
ssResid = sum(yResid .^ 2);
ssTotal = (length(y)-1) * var(y);
rsq = 1 - ssResid/ssTotal;

end