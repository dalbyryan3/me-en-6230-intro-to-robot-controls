%% ME EN 6230 Lab 2 Ryan Dalby
% Robustness Comparison 
% close all;
set(groot, 'DefaultTextInterpreter', 'none') % Prevents underscore from becoming subscript

% errors are in degrees

% PD feedforward comp w/ disturbance
feedforwardcomp_fast_rms = [0.874 0.488];
feedforwardcomp_fast_max = [3.43 1.17];

% IDC w/ disturbance
idc_fast_rms = [0.788 0.531];
idc_fast_max = [3.56 1.47];

% Sliding mode control w/ disturbance
slidingmodecontrol_fast_rms = [0.582 0.338];
slidingmodecontrol_fast_max = [2.71 0.969];

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

