function settings = getTPOSettings()
%GETTPOSETTINGS Define TPO and transducer specific settings.
%
% DESCRIPTION:
%     getTPOSettings defines literals related to the TPO and the connected
%     transducer. Edit this file to specify hardware specific parameters.
%
% OUTPUTS:
%     settings      - structure with the following fields:
%                       .number_channels
%                       .maximum_power_value
%                       .minimum_frequency
%                       .maximum_frequency
%                       .minimum_focus
%                       .maximum_focus
%
% ABOUT:
%     author        - Bradley Treeby
%     date          - 29th November 2022
%     last update   - 3rd July 2023

settings.number_channels        = 4;
settings.maximum_power_value    = 30;
settings.minimum_frequency      = 0.1e6;
settings.maximum_frequency      = 10e6;
settings.minimum_focus          = 33.6e-3;
settings.maximum_focus          = 75.2e-3;
