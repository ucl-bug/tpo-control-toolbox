% Processing script for experiments 1 and 2 of the auditory artefact study.
%
% author: Bradley Treeby
% date:  20th November 2020
% last update: 20th November 2020

% sham
sham_response = response(pulse_sequence == 0);
sham_response(isnan(sham_response)) = [];
sham_audible = 100 * sum(sham_response == 1) / length(sham_response);

% active
active1_response = response(pulse_sequence == 1);
active1_response(isnan(active1_response)) = [];
active1_audible = 100 * sum(active1_response == 1) / length(active1_response);

% active
active2_response = response(pulse_sequence == 2);
active2_response(isnan(active2_response)) = [];
active2_audible = 100 * sum(active2_response == 1) / length(active2_response);

% active
active3_response = response(pulse_sequence == 3);
active3_response(isnan(active3_response)) = [];
active3_audible = 100 * sum(active3_response == 1) / length(active3_response);

% active
active4_response = response(pulse_sequence == 4);
active4_response(isnan(active4_response)) = [];
active4_audible = 100 * sum(active4_response == 1) / length(active4_response);

% display results
disp(['Sham audible:     ' num2str(sham_audible) '% (' num2str(sum(sham_response == 1)) ' of ' num2str(length(sham_response)) ' trials)']);
disp(['Active 1 audible: ' num2str(active1_audible) '% (' num2str(sum(active1_response == 1)) ' of ' num2str(length(active1_response)) ' trials)']);
disp(['Active 2 audible: ' num2str(active2_audible) '% (' num2str(sum(active2_response == 1)) ' of ' num2str(length(active2_response)) ' trials)']);
disp(['Active 3 audible: ' num2str(active3_audible) '% (' num2str(sum(active3_response == 1)) ' of ' num2str(length(active3_response)) ' trials)']);
disp(['Active 4 audible: ' num2str(active4_audible) '% (' num2str(sum(active4_response == 1)) ' of ' num2str(length(active4_response)) ' trials)']);

clearvars;
