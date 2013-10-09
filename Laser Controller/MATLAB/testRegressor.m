% Alan Zucconi
function [ results ] = testRegressor( trainIn, params  )

% Assumptions:
%   - trainIn has two columsn
%   - trainOut has one colum

dataPoints = size(trainIn,1);

% Covariance matrix

%basisFunctions = size(params.mu,1);
   
%phi = ones(dataPoints, basisFunctions +1);

% Selects a number of random input elements(lat, long)
% to be the means (mu values) of the basis functions

%     % r: loops the data points
%     for r = 1:dataPoints
%         dataPoint = trainIn(r,:);   % (lat, long)
%         % c : loops the basis functions
%         for c = 1:basisFunctions
%             % No multiplicative coefficient because it will be incorporeted by
%             % wML
%             aaa = dataPoint-params.mu(c, :);
%             phi(r,c) = exp(  -(aaa) * params.Sigma * (aaa)' / 2   );
%             %phi(r,c) = exp(  -(dataPoint-params.mu(c, :)) * params.Sigma * (dataPoint-params.mu(c, :))' / 2   );
%         end
%     end

basis = params.basis;
% 
% 
% % Evaluate phi --------------
% phi_e = zeros(size(phi));
% % r: loops the data points
% for r = size(phi,1)
%     dataPoint = trainIn(r,:);   % (lat, long)
%     % c : loops the basis functions
%     for c = size(phi,2)
%         phi_e(r,c) = phi{r,c}(dataPoint);
%     end
% end


phi = zeros(dataPoints, length(basis));
% r: loops the data points
for r = 1:size(phi,1)
    dataPoint = trainIn(r,:);   % (lat, long)
    % c : loops the basis functions
    for c = 1:size(phi,2)
        phi(r,c) = basis{c}(dataPoint);
    end
end

results = phi * params.wML;

end