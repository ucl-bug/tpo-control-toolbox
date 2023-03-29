function runTPO(transducerIndex, intensityIndex, pulseDurationIndex, pulseRepetitionIntervalIndex, repeatsIndex)
%RUNTPO Run TPO for skull heating study.
%
% DESCRIPTION:
%     runTPO runs the TPO based on the selections made in controlGUI. All
%     inputs are integers, which index the settings defined below.
%
%     The intensity values come from a hydrophone calibration of each
%     transducer.
%
%     The timing is provided using the psych toolbox.
%
%     For the H115 transducer, both elements are driven in phase. For the
%     H104 transducer, only a single channel of the TPO is used.
%
% INPUTS:
%     transducerIndex    - 1: H115 (250 kHz)
%                          2: H104 (500 kHz)
%
%     intensityIndex     - 1: 5 W/cm^2
%                          2: 10 W/cm^2
%                          3: 20 W/cm^2
%
%     pulseDurationIndex - 1: 75 ms
%                          2: 150 ms
%                          3: 300 ms
%
%     pulseRepetitionIntervalIndex
%                        - 1: 1 s
%                        - 2: 2 s
%                        - 3: 4 s
%
%     repeatsIndex       - 1: 50 repeats
%
% USAGE:
%     runTPO(transducerIndex, intensityIndex, pulseDurationIndex, pulseRepetitionIntervalIndex, repeatsIndex)
% 
% ABOUT:
%     author             - Bradley Treeby
%     date               - 20th February 2023
%     last update        - 1st March 2023

arguments
    transducerIndex (1, 1) {mustBeInteger, mustBeInRange(transducerIndex, 1, 2)}
    intensityIndex (1, 1) {mustBeInteger, mustBeInRange(intensityIndex, 1, 4)}
    pulseDurationIndex (1, 1) {mustBeInteger, mustBeInRange(pulseDurationIndex, 1, 3)}
    pulseRepetitionIntervalIndex (1, 1) {mustBeInteger, mustBeInRange(pulseRepetitionIntervalIndex, 1, 3)}
    repeatsIndex (1, 1) {mustBeInteger, mustBeInRange(repeatsIndex, 1, 1)}
end

% connect to TPO
serialTPO = connectTPO();

% set transmit frequency (Hz)
if transducerIndex == 1
    drivingFreq = 250e3;
else 
    drivingFreq = 500e3;
end
setFreq(serialTPO, drivingFreq);

% set phases to zero
setPhase(serialTPO, 1, 0);
setPhase(serialTPO, 2, 0);

% no ramping
setRampMode(serialTPO, 0);

% reset timing values to avoid set order problems
setBurst(serialTPO, 1e-3);      
setPeriod(serialTPO, 500e-3); 
setTimer(serialTPO, 1);

% set timing properties to emit a single burst (s)
switch pulseDurationIndex
    case 1
        pulseDuration = 75e-3;
    case 2
        pulseDuration = 150e-3;
    case 3
        pulseDuration = 300e-3;
end
setBurst(serialTPO, pulseDuration);      
setPeriod(serialTPO, pulseDuration); 
setTimer(serialTPO, pulseDuration);

% high-speed trigger mode
setTriggerMode(serialTPO, 2);

% set electrical power (W), where settings come from calibration
% measurements
if transducerIndex == 1

    % H115
    switch intensityIndex
        case 1
            power = 1.3818; % 5 W/cm^2
        case 2
            power = 2.7758; % 10 W/cm^2
        case 3
            power = 5.5636; % 20 W/cm^2
        case 4
            error('40 W/cm^2 not setup for this transducer');
    end
    setPower(serialTPO, power);

else

    % H104
    switch intensityIndex
        case 1
            power = 0.3877;  % 5 W/cm^2
        case 2
            power = 0.77364; % 10 W/cm^2
        case 3
            power = 1.5455;  % 20 W/cm^2
        case 4
            power = 3.0893;  % 40 W/cm^2
    end
    setPowerSingleElementTx(serialTPO, power);

end

% number of repeats
switch repeatsIndex
    case 1
        repeats = 50;
end

% pulse repetition interval (s)
switch pulseRepetitionIntervalIndex
    case 1
        pulseRepetitionInterval = 1;
    case 2
        pulseRepetitionInterval = 2;
    case 3
        pulseRepetitionInterval = 4;
end

% start transmitting pulses
reference_time = GetSecs;
for pulseIndex = 1:repeats

    % arm the TPO
    fprintf(serialTPO, 'ARM');

    % wait until stimulus time
    start_time = reference_time + pulseIndex * pulseRepetitionInterval;
    WaitSecs('UntilTime', start_time);
    
    % trigger the ultrasound
    fprintf(serialTPO, '\r');
    disp(['Transmitting pulse ' num2str(pulseIndex) ' of ' num2str(repeats)]);
    
    % check for exit flag
    exitFlag = evalin('base', 'exitFlag');
    if exitFlag
        disp('Sequence aborted!');
        return;
    end

    % short pause
    WaitSecs(2 * pulseDuration);

end
