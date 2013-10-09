% Alan Zucconi
%function [ params ] = trainRegressor( trainIn, trainOut, basisFunctions)
function [ params ] = trainRegressor( trainIn, trainOut, bf)
% Assumptions:
%   - trainIn has four columsn
%   - trainOut has two colum

dataPoints = size(trainIn,1);
%dimensions = size(trainIn,2);

% Covariance matrix
%Sigma = [   1 / var(trainIn(:,1)),  0                       ;
%        0                       1 / var(trainIn(:,2))   ];
%Sigma = diag(cov(trainIn))
%Sigma = inv(cov(trainIn));
%Sigma = eye(dimensions)*cov(trainIn)
Sigma = inv(cov(trainIn));




% Selects a number of random input elements(lat, long)
% to be the means (mu values) of the basis functions
%muIndices = randperm(dataPoints, basisFunctions);   % Random unique indices of selected inputs
%mu = trainIn(muIndices, :);
mins = min(trainIn);
maxs = max(trainIn);
diffs = maxs - mins;
steps = diffs / (bf-1);
%steps = ones(1,4)*basisFunctions / diffs
%mu = zeros(basisFunctions^2, 1);

% a = mins(1):steps(1):maxs(1)
% b = mins(2):steps(2):maxs(2)
% c = mins(3):steps(3):maxs(3)
% d = mins(4):steps(4):maxs(4)
%  
% [I1, I2, I3, I4] = ndgrid ...
%     (   mins(1):steps(1):maxs(1),   ...
%         mins(2):steps(2):maxs(2),   ...
%         mins(3):steps(3):maxs(3),   ...
%         mins(4):steps(4):maxs(4)    ...
%     );
% I1
% mu = [I1 I2 I3 I4];
% size(mu)

basisFunctions = bf^4;

% Mus uniformely distributed in the parameters space.
% This solution might not be the preferred one, since not all the
% parameters have the same influences on the final results.
mu = zeros(basisFunctions, 4);
i = 1;
for v1             = mins(1):steps(1):maxs(1)
    for v2         = mins(2):steps(2):maxs(2)
        for v3     = mins(3):steps(3):maxs(3)
            for v4 = mins(4):steps(4):maxs(4)
                mu(i, :) = [v1 v2 v3 v4];
                i = i+1;
            end
        end
    end
end




%phi = ones(dataPoints, basisFunctions +1);
%phi = cell(dataPoints, basisFunctions+1);
basis = cell(basisFunctions+1, 1);

%i = 1;
% r: loops the data points
%for r = 1:dataPoints
    %dataPoint = trainIn(r,:);   % (lat, long)
    % c : loops the basis functions
for c = 1:basisFunctions
    %aaa = dataPoint-mu(c, :);
    %phi(r,c) = exp(  -(aaa) * Sigma * (aaa)' / 2   );
    %phi{r,c} = @(x) exp(  -(x-mu(c, :)) * Sigma * (x-mu(c, :))' / 2   );
    %phi(r,c) = exp(  -(dataPoint-mu(c, :)) * Sigma * (dataPoint-mu(c, :))' / 2   );
    %i = i + 1;





    basis{c} = @(x) exp(  -(x-mu(c, :)) * Sigma * (x-mu(c,:))' / 2   );

    %f = @(x, mu, Sigma) exp(  -(x-mu(c)) * Sigma * (x-mu(c))' / 2   );
    %basis{c} = @(x) f(x, mu, Sigma);

    %drawnow
end
    
% Constant term
basis{end} = @(x) 1;
%end
%i
%size(phi)
% The last columns is not made of gaussian functions
% but contains the constant "1".
% This helps to "shift" solutions up and down without
% the need to rearrange coefficients
%phi(:, basisFunctions +1) = ones(:,1);

% Evaluate phi --------------
% phi = zeros(dataPoints, basisFunctions+1);
% %c : loops the basis functions
% for c = 1:length(basis)
%     %arrayfun(basis{c}, trainIn(:, 1)    )
%     arrayfun(basis{c}, 1    )
%     phi(:, c) = arrayfun(basis{c}, trainIn(:, 1:4)    );
% end
% phi

phi = zeros(dataPoints, length(basis));
% r: loops the data points
for r = 1:size(phi,1)
    dataPoint = trainIn(r,:);   % (lat, long)
    % c : loops the basis functions
    for c = 1:size(phi,2)
        phi(r,c) = basis{c}(dataPoint);
    end
end

params = struct;
%params.phi = phi;
params.basis = basis;
params.phi = phi;
%params.Sigma = Sigma;
%params.mu = mu;
%params.phi = phi;
params.wML = pinv(phi)*trainOut;

end