%% ME EN 6230 Lab 1 Ryan Dalby
% Controller Comparison 
close all;
set(groot, 'DefaultTextInterpreter', 'none') % Prevents underscore from becoming subscript

% errors are in degrees
% PD Controller
m11_slow_rms = [0.532 0.417];
m11_slow_max = [1.57 1.1];
m11_fast_rms = [1.57 0.722];
m11_fast_max = [5.23 1.44];

% PD feedback comp
m12_slow_rms = [0.237 0.326];
m12_slow_max = [0.756 0.766];
m12_fast_rms = [1.12 0.627];
m12_fast_max = [3.84 1.8];

% PD feedforward comp
m13_slow_rms = [0.222 0.304];
m13_slow_max = [0.548 0.665];
m13_fast_rms = [0.246 0.228];
m13_fast_max = [0.805 0.638];

% IDC 
m21_slow_rms = [0.174 0.366];
m21_slow_max = [0.435 0.853];
m21_fast_rms = [0.209 0.276];
m21_fast_max = [0.768 0.760];

slow_rms = [m11_slow_rms; m12_slow_rms; m13_slow_rms; m21_slow_rms];
fast_rms = [m11_fast_rms; m12_fast_rms; m13_fast_rms; m21_fast_rms];
slow_max = [m11_slow_max; m12_slow_max; m13_slow_max; m21_slow_max];
fast_max = [m11_fast_max; m12_fast_max; m13_fast_max; m21_fast_max];

controller_labels = {'PD Control', 'Feedback Comp', 'Feedforward Comp', 'IDC'};
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

