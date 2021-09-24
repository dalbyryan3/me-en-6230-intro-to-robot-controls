%% ME EN 6230 Problem Set 6 Ryan Dalby
% Controller Comparison 
close all;
set(groot, 'DefaultTextInterpreter', 'none') % Prevents underscore from becoming subscript

% errors are in degrees
% Model 1.1- PD Controller
m11_slow_rms = [0.538 0.219];
m11_slow_max = [1.04 0.335];
m11_fast_rms = [1.46 0.637];
m11_fast_max = [3.67 1.17];

% Model 1.2- PD feedback comp
m12_slow_rms = [0.0373 0.0241];
m12_slow_max = [0.0941 0.0576];
m12_fast_rms = [0.973 0.56];
m12_fast_max = [2.45 1.49];

% Model 1.3- PD feedforward comp
m13_slow_rms = [0.00907 0.00573];
m13_slow_max = [0.0229 0.0137];
m13_fast_rms = [0.235 0.131];
m13_fast_max = [0.595 0.345];

% Model 2.1- IDC 
m21_slow_rms = [0.00278 0.00267];
m21_slow_max = [0.00593 0.00583];
m21_fast_rms = [0.0139 0.0135];
m21_fast_max = [0.0285 0.0296];

slow_rms = [m11_slow_rms; m12_slow_rms; m13_slow_rms; m21_slow_rms];
fast_rms = [m11_fast_rms; m12_fast_rms; m13_fast_rms; m21_fast_rms];
slow_max = [m11_slow_max; m12_slow_max; m13_slow_max; m21_slow_max];
fast_max = [m11_fast_max; m12_fast_max; m13_fast_max; m21_fast_max];

controller_labels = {'PD Control (1.1)', 'Feedback Comp (1.2)', 'Feedforward Comp (1.3)', 'IDC (2.1)'};
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

