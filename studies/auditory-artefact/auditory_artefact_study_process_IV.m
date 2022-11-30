% % Processing script for experiment 4 of the auditory artefact study.
%
% author: Bradley Treeby
% date: 20th May 2021
% last update: 20th May 2021

% sham
sham_response1 = response(pulse_sequence == 0);
sham_response1(isnan(sham_response1)) = [];
sham_audible1 = 100 * sum(sham_response1 == 1) / length(sham_response1);

% sham with mask
sham_response2 = response(pulse_sequence == 0);
sham_response2(isnan(sham_response2)) = [];
sham_audible2 = 100 * sum(sham_response2 == 1) / length(sham_response2);

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

% active
active5_response = response(pulse_sequence == 5);
active5_response(isnan(active5_response)) = [];
active5_audible = 100 * sum(active5_response == 1) / length(active5_response);

% display results
disp(['Sham    no mask        :       ' num2str(sham_audible1) '% (' num2str(sum(sham_response1 == 1)) ' of ' num2str(length(sham_response1)) ' trials)']);
disp(['Sham    mask           :       ' num2str(sham_audible2) '% (' num2str(sum(sham_response1 == 1)) ' of ' num2str(length(sham_response1)) ' trials)']);
disp(['Active  mask    no ramp:       ' num2str(active2_audible) '% (' num2str(sum(active2_response == 1)) ' of ' num2str(length(active2_response)) ' trials)']);
disp(['Active  mask    ramp   :       ' num2str(active3_audible) '% (' num2str(sum(active3_response == 1)) ' of ' num2str(length(active3_response)) ' trials)']);
disp(['Active  no mask ramp   :       ' num2str(active4_audible) '% (' num2str(sum(active4_response == 1)) ' of ' num2str(length(active4_response)) ' trials)']);
disp(['Active  random         :       ' num2str(active5_audible) '% (' num2str(sum(active5_response == 1)) ' of ' num2str(length(active5_response)) ' trials)']);

clearvars;
