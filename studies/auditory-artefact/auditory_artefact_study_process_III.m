% Processing script for experiment 3 of the auditory artefact study.
%
% author: Bradley Treeby
% date: 20th May 2021
% last update: 20th May 2021

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

% display results
disp(['Sham audible:     ' num2str(sham_audible) '% (' num2str(sum(sham_response == 1)) ' of ' num2str(length(sham_response)) ' trials)']);
disp(['Active 1 audible: ' num2str(active1_audible) '% (' num2str(sum(active1_response == 1)) ' of ' num2str(length(active1_response)) ' trials)']);
disp(['Active 2 audible: ' num2str(active2_audible) '% (' num2str(sum(active2_response == 1)) ' of ' num2str(length(active2_response)) ' trials)']);

clearvars;
