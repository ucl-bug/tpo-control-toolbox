% Script to replicate theta burst protocol from
% https://doi.org/10.1002/ana.26294 using a NeuroFUS TPO and CTX-500.
%
% Reported protocol is:
%    Burst: 20 ms
%    Period: 200 ms
%    Timer: 80 s
%    Isppa(water): 2.26 W/cm^2

clearvars;

%% Connect to TPO

serialTPO = connectTPO();

%% Setup theta burst protocol

setFreq(serialTPO, 500e3);      % Should always be 500 kHz
setFocus(serialTPO, 35e-3);     % Steering range is ~35 to 75 mm
setPower(serialTPO, 1);         % Software max is 1.12

setTimer(serialTPO, 80);        % 80 s
setPeriod(serialTPO, 200e-3);   % 200 ms
setBurst(serialTPO, 20e-3);     % 20 ms

%% Start sonication

transmitStart(serialTPO);
