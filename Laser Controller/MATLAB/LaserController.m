classdef LaserController < hgsetget
    properties
        Ca; % Position of first LA
        Cb; % Position of second LA
        P;  % Position of laser
        R_0;    % Length of LA arm when fully retracted
        R_100;  % Length of LA arm when fully extended
    end
    
    methods
        function this = LaserController (parameters)
            this.setParameters(parameters);
        end
        
        function this = set.Parameters (this, parameters)
            this.Ca    = parameters.Ca;
            this.Cb    = parameters.Cb;
            this.P     = parameters.P;
            this.R_0   = parameters.R_0;
            this.R_100 = parameters.R_100;
        end
    end
    
end

