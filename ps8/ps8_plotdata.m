%% ME EN 6230 Problem Set 8 Ryan Dalby
% close all;
set(groot, 'DefaultTextInterpreter', 'none') % Prevents underscore from becoming subscript

% Extract necessary data, will error if the data does not exist
time = errors.time; % s
model_title = extractBefore(errors.blockName, "/");
joint_errors = rad2deg(errors.signals.values); % deg
op_errors = xy - xy_d; % m
actual_trajectory = xy; % m
desired_trajectory = xy_d; % m

% RMS Joint Errors
RMS_joint_error = rms(joint_errors); % deg
% Max Joint Errors
max_joint_error = max(abs(joint_errors)); % deg

% RMS Operational Space Errors
RMS_op_error = rms(op_errors); % deg
% Max Operational Space Errors
max_op_error = max(abs(op_errors)); % deg

% Plot Joint Errors vs Time
if strcmp(model_title, 'jacobian_inverse_control')
    figure;
    plot(time, joint_errors(:,1), 'b-');
    hold on;
    plot(time, joint_errors(:,2), 'r--');
    hold on;
    text(0.01,0.10,append('RMS Error = ', mat2str(RMS_joint_error,3),' deg'), 'Units', 'normalized');
    hold on;
    text(0.01,0.05,append('Max Error = ', mat2str(max_joint_error,3),' deg'), 'Units', 'normalized');
    title(append('Joint Errors vs. Time for ', model_title));
    xlabel('time (s)');
    ylabel('error (deg)');
    legend('joint 1', 'joint 2');
end

% Plot Operational Space Errors vs Time
figure;
plot(time, op_errors(:,1), 'b-');
hold on;
plot(time, op_errors(:,2), 'r--');
hold on;
text(0.01,0.10,append('RMS Error = ', mat2str(RMS_op_error,3),' m'), 'Units', 'normalized');
hold on;
text(0.01,0.05,append('Max Error = ', mat2str(max_op_error,3),' m'), 'Units', 'normalized');
title(append('Operational Space Errors vs. Time for ', model_title));
xlabel('time (s)');
ylabel('error (m)');
legend('joint 1', 'joint 2');

% Plot End-Effector Trajectory
figure;
plot(xy(:,1), xy(:,2), 'b-');
hold on;
plot(xy_d(:,1), xy_d(:,2), 'r--');
title(append('End-Effector Trajectory for ', model_title));
xlabel('x (m)');
ylabel('y (m)');
legend('actual', 'desired');
