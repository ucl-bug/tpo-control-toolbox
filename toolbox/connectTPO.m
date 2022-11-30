function serialTPO = connectTPO()
%CONNECTTPO Connect to the TPO
%
% DESCRIPTION:
%     connectTPO establishes a new connection to the TPO via USB. It
%     creates a serial object and communicates via the com port.
%
% USAGE:
%     serialTPO = connectTPO()
%
% OUTPUTS:
%     serialTPO     - serial connection to the TPO
%
% ABOUT:
%     author        - Bradley Treeby
%     date          - 18th November 2019
%     last update   - 18th November 2019
%
% Function based on code provided by Sonic Concepts.

% close existing com port connections
newobjs = instrfind;
if ~isempty(newobjs)
    fclose(newobjs);
end

% find available port and sets up serial object
% NOTE this is untested in environments outside of windows
try
    COMports = comPortSniff; % cell containing string identifier of com port
catch
    error('No COM ports found, please check TPO');
end

% remove any empty cells
COMports = COMports(~cellfun('isempty',COMports));
len = length(COMports(:));
COMports = reshape(COMports,[len/2 2]);

% pick out TPO port using default name
tempInd = strfind(COMports(:,1), 'Arduino Due');
indTPO = find(not(cellfun('isempty', tempInd)));
if isempty(indTPO)
    
    % if not find, try again using generic name
    tempInd = strfind(COMports(:,1), 'USB Serial Device');
    indTPO = find(not(cellfun('isempty', tempInd)));
    
    % if still not found, throw error
    if isempty(indTPO)
        error( 'No TPO detected, please check your USB and power connections.')
    end
    
end

% trim off multiple matches and takes first
indTPO = indTPO(1); 

% open COM port to TPO
disp(['COM port: ' num2str(indTPO) '-' COMports{indTPO,1}]);
serialTPO = serial(['COM' num2str(COMports{indTPO,2})],'BaudRate', 115200,'DataBits', 8, 'Terminator', 'CR');
fopen(serialTPO);

% 4 second pause to wait for power-on reset
pause(4);

% dummy read to get TPO name and software version (print to display)
reply = fscanf(serialTPO); 
disp(reply);

% set TPO to remote mode
setControlMode(serialTPO, 0);
