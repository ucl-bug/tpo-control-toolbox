function serialTPO = setupTPOV1()
% Function to setup the TPO with the parameters used for the V1 ultrasound
% neurostimulation study. The power is set in the powerOnTPO function.
%
% author: Bradley Treeby
% date: 1 November 2019
% last update: 25th June 2021

% =========================================================================
% DEFINE LITERALS
% =========================================================================

% transducer parameters
xdrCenterFreq   = 270e3;  	% in Hertz
xdrPhaseElem1   = 0;        % in degrees
xdrPhaseElem2   = 66.3;     % in degrees

% signal properties
tpoBurstLength  = 3.25e-3;  % in seconds
tpoBurstPeriod  = 4e-3;     % in seconds
tpoRampLength   = 1e-3;     % in seconds
tpoTimer        = 300e-3;   % in seconds, 0 for indefinite
tpoRampMode     = 2;        % 0 = none, 1 = linear, 2 = Tukey, 3 = log, 4 = exp
tpoTriggerMode  = 0;        % 0 = no input trigger, 1 = standard, 2 = high-speed

% =========================================================================
% SET SYSTEM PARAMETERS ON TPO
% =========================================================================

% connect to TPO
serialTPO = connectTPO();

% set transmit frequency 
setFreq(serialTPO, xdrCenterFreq);

% set phase
setPhase(serialTPO, 1, xdrPhaseElem1);
setPhase(serialTPO, 2, xdrPhaseElem2);

% set burst properties and ramp
setBurst        (serialTPO, tpoBurstLength);      
setPeriod       (serialTPO, tpoBurstPeriod); 
setRampMode     (serialTPO, tpoRampMode);
if tpoRampMode ~= 0
    setRampLength   (serialTPO, tpoRampLength);
end
setTimer        (serialTPO, tpoTimer);
setTriggerMode  (serialTPO, tpoTriggerMode);

% set power (always set power after frequency or you may limit TPO)
powerOnTPO(serialTPO);
