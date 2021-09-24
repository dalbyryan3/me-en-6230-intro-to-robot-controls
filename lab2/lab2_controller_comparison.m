%% ME EN 6230 Lab 2 Ryan Dalby
% Controller Comparison 
% close all;
set(groot, 'DefaultTextInterpreter', 'none') % Prevents underscore from becoming subscript

% errors are in degrees
% PD Controller
pd_slow_rms = [0.532 0.417];
pd_slow_max = [1.57 1.1];
pd_fast_rms = [1.57 0.722];
pd_fast_max = [5.23 1.44];

% PD feedback comp
feedbackcomp_slow_rms = [0.237 0.326];
feedbackcomp_slow_max = [0.756 0.766];
feedbackcomp_fast_rms = [1.12 0.627];
feedbackcomp_fast_max = [3.84 1.8];

% PD feedforward comp
feedforwardcomp_slow_rms = [0.222 0.304];
feedforwardcomp_slow_max = [0.548 0.665];
feedforwardcomp_fast_rms = [0.246 0.228];
feedforwardcomp_fast_max = [0.805 0.638];

% IDC
idc_slow_rms = [0.174 0.366];
idc_slow_max = [0.435 0.853];
idc_fast_rms = [0.209 0.276];
idc_fast_max = [0.768 0.760];

% Sliding mode control
slidingmodecontrol_slow_rms = [0.154 0.311];
slidingmodecontrol_slow_max = [0.425 0.722];
slidingmodecontrol_fast_rms = [0.168 0.253];
slidingmodecontrol_fast_max = [0.643 0.679];

slow_rms = [pd_slow_rms; feedbackcomp_slow_rms; feedforwardcomp_slow_rms; idc_slow_rms; slidingmodecontrol_slow_rms];
fast_rms = [pd_fast_rms; feedbackcomp_fast_rms; feedforwardcomp_fast_rms; idc_fast_rms; slidingmodecontrol_fast_rms];
slow_max = [pd_slow_max; feedbackcomp_slow_max; feedforwardcomp_slow_max; idc_slow_max; slidingmodecontrol_slow_max];
fast_max = [pd_fast_max; feedbackcomp_fast_max; feedforwardcomp_fast_max; idc_fast_max; slidingmodecontrol_fast_max];

controller_labels = {'PD Control', 'Feedback Comp', 'Feedforward Comp', 'IDC', 'Sliding Mode Control'};
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

