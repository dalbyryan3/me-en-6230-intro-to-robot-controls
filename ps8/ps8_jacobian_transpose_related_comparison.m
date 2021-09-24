%% ME EN 6230 Problem Set 8 Ryan Dalby
% Jacobian Transpose Related Controller Comparison 
% close all;
set(groot, 'DefaultTextInterpreter', 'none') % Prevents underscore from becoming subscript

% errors are in meters
% Operational space jacobian transpose controller
jacobian_transpose_slow_rms = [0.000406 0.00025];
jacobian_transpose_slow_max = [0.00101 0.000473];
jacobian_transpose_fast_rms = [0.00147 0.00105];
jacobian_transpose_fast_max = [0.00434 0.00285];

% Operational space inverse dynamics controller
op_space_idc_slow_rms = [1.36e-05 1.75e-05];
op_space_idc_slow_max = [2.8e-05 4.28e-05];
op_space_idc_fast_rms = [0.000353 0.000351];
op_space_idc_fast_max = [0.000519 0.000541];

% Operational space inverse dynamics controller
op_space_robust_slow_rms = [5.92e-07 6.81e-07];
op_space_robust_slow_max = [4.24e-06 1.52e-06];
op_space_robust_fast_rms = [1.38e-05 1.36e-05];
op_space_robust_fast_max = [2.71e-05 2.63e-05];


slow_rms = [jacobian_transpose_slow_rms; op_space_idc_slow_rms; op_space_robust_slow_rms];
fast_rms = [jacobian_transpose_fast_rms; op_space_idc_fast_rms; op_space_robust_slow_max];
slow_max = [jacobian_transpose_slow_max; op_space_idc_slow_max; op_space_robust_fast_rms];
fast_max = [jacobian_transpose_fast_max; op_space_idc_fast_max; op_space_robust_fast_max];

controller_labels = {'Op-Space Jacobian Transpose Control', 'Op-Space Inverse Dynamics Controller', 'Op-Space Robust Control'};
controller_labels_cat = categorical(controller_labels);
controller_labels_cat = reordercats(controller_labels_cat, string(controller_labels_cat));

figure;
bar(controller_labels_cat,slow_rms);
title('Low Speed (0.2cps) RMS Error by Controller Type');
legend('Joint 1', 'Joint 2');
ylabel('RMS Error in Meters');

figure;
bar(controller_labels_cat,fast_rms);
title('High Speed (1cps) RMS Error by Controller Type');
legend('Joint 1', 'Joint 2');
ylabel('RMS Error in Meters');

figure;
bar(controller_labels_cat,slow_max);
title('Low Speed (0.2cps) Max Error by Controller Type');
legend('Joint 1', 'Joint 2');
ylabel('Max Error in Meters');

figure;
bar(controller_labels_cat,fast_max);
title('High Speed (1cps) Max Error by Controller Type');
legend('Joint 1', 'Joint 2');
ylabel('Max Error in Meters');
