function settings = getTPOSettings()
%POWEROFFTPO Turn TPO power off
%
% DESCRIPTION:
%     getTPOSettings defines literals related to the TPO and the connected
%     transducer. Edit this file to specify hardware specific parameters.
%
% OUTPUTS:
%     settings      - struture with the following fields:
%                       .number_channels
%                       .maximum_power_value
%                       .minimum_frequency
%                       .maximum_frequency   
%
% ABOUT:
%     author        - Bradley Treeby
%     date          - 29th November 2022
%     last update   - 30th November 2022

settings.number_channels        = 2;
settings.maximum_power_value    = 30;
settings.minimum_frequency      = 0.1e6;
settings.maximum_frequency      = 10e6;
