%% ME EN 6230 Problem Set 7 Ryan Dalby
% Controller Comparison 
% close all;
set(groot, 'DefaultTextInterpreter', 'none') % Prevents underscore from becoming subscript

% errors are in degrees
% PD Controller
pd_slow_rms = [0.538 0.219];
pd_slow_max = [1.04 0.335];
pd_fast_rms = [1.46 0.637];
pd_fast_max = [3.67 1.17];

% PD feedback comp
feedbackcomp_slow_rms = [0.0373 0.0241];
feedbackcomp_slow_max = [0.0941 0.0576];
feedbackcomp_fast_rms = [0.973 0.56];
feedbackcomp_fast_max = [2.45 1.49];

% PD feedforward comp
feedforwardcomp_slow_rms = [0.00907 0.00573];
feedforwardcomp_slow_max = [0.0229 0.0137];
feedforwardcomp_fast_rms = [0.235 0.131];
feedforwardcomp_fast_max = [0.595 0.345];

% IDC (Note this was re-run with same PD gain values as sliding control for
% fair comparison)
idc_slow_rms = [0.00668 0.00702];
idc_slow_max = [0.0167 0.0167];
idc_fast_rms = [0.167 0.166];
idc_fast_max = [0.426 0.447];

% Sliding mode control
slidingmodecontrol_slow_rms = [0.0003585,0.0003734];
slidingmodecontrol_slow_max = [0.00142,0.00114];
slidingmodecontrol_fast_rms = [0.0194,0.0218];
slidingmodecontrol_fast_max = [0.00795,0.00855];

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

