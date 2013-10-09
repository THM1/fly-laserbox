function [yi] = linearInterpolation (x0, y0, x1, y1, xi)
    yi = y0 + (y1 - y0) * ((xi-x0)/(x1-x0));
end