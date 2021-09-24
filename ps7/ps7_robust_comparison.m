%% ME EN 6230 Problem Set 7 Ryan Dalby
% Robustness Comparison 
% close all;
set(groot, 'DefaultTextInterpreter', 'none') % Prevents underscore from becoming subscript

% errors are in degrees

% PD feedforward comp w/ disturbance
feedforwardcomp_fast_rms = [0.53 0.489];
feedforwardcomp_fast_max = [0.94 0.858];

% IDC w/ disturbance
idc_fast_rms = [0.385 0.568];
idc_fast_max = [0.787 1.03];

% Sliding mode control w/ disturbance
slidingmodecontrol_fast_rms = [0.00927 0.0132];
slidingmodecontrol_fast_max = [0.0195 0.0327];

fast_rms = [feedforwardcomp_fast_rms; idc_fast_rms; slidingmodecontrol_fast_rms];
fast_max = [feedforwardcomp_fast_max; idc_fast_max; slidingmodecontrol_fast_max];

controller_labels = {'Feedforward Comp', 'IDC', 'Sliding Mode Control'};
controller_labels_cat = categorical(controller_labels);
controller_labels_cat = reordercats(controller_labels_cat, string(controller_labels_cat));

figure;
bar(controller_labels_cat,fast_rms);
title('High Speed (1cps) RMS Error with Disturbance by Controller Type');
legend('Joint 1', 'Joint 2');
ylabel('RMS Error in Degrees');

figure;
bar(controller_labels_cat,fast_max);
title('High Speed (1cps) Max Error with Disturbance by Controller Type');
legend('Joint 1', 'Joint 2');
ylabel('Max Error in Degrees');

