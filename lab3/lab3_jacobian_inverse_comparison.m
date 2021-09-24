%% ME EN 6230 Lab 3 Ryan Dalby
% Jacobian Inverse and Joint Space PD Controller Comparison 
% close all;
set(groot, 'DefaultTextInterpreter', 'none') % Prevents underscore from becoming subscript

% errors are in degrees
% Joint Space PD Controller
pd_slow_rms = [0.532 0.417];
pd_slow_max = [1.57 1.1];
pd_fast_rms = [1.57 0.722];
pd_fast_max = [5.23 1.44];

% Jacobian Inverse Controller
feedbackcomp_slow_rms = [];
feedbackcomp_slow_max = [];
feedbackcomp_fast_rms = [];
feedbackcomp_fast_max = [];


slow_rms = [pd_slow_rms; feedbackcomp_slow_rms];
fast_rms = [pd_fast_rms; feedbackcomp_fast_rms];
slow_max = [pd_slow_max; feedbackcomp_slow_max];
fast_max = [pd_fast_max; feedbackcomp_fast_max];

controller_labels = {'Joint Space PD Control', 'Jacobian Inverse control'};
controller_labels_cat = categorical(controller_labels);
controller_labels_cat = reordercats(controller_labels_cat, string(controller_labels_cat));

figure;
bar(controller_labels_cat,slow_rms);
title('Low Speed (0.2cps) RMS Error by Controller Type');
legend('Joint 1', 'Joint 2');
ylabel('RMS Error in Degrees');

figure;
bar(controller_labels_cat,fast_rms);
title('High Speed (1cps) RMS Error by Controller Type');
legend('Joint 1', 'Joint 2');
ylabel('RMS Error in Degrees');

figure;
bar(controller_labels_cat,slow_max);
title('Low Speed (0.2cps) Max Error by Controller Type');
legend('Joint 1', 'Joint 2');
ylabel('Max Error in Degrees');

figure;
bar(controller_labels_cat,fast_max);
title('High Speed (1cps) Max Error by Controller Type');
legend('Joint 1', 'Joint 2');
ylabel('Max Error in Degrees');

