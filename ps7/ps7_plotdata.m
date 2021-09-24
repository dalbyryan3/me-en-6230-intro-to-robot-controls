%% ME EN 6230 Problem Set 7 Ryan Dalby
% close all;
set(groot, 'DefaultTextInterpreter', 'none') % Prevents underscore from becoming subscript

% Extract necessary data, will error if the data does not exist
time = errors.time; % s
model_title = extractBefore(errors.blockName, "/Joint Errors");
joint_errors = rad2deg(errors.signals.values); % deg
actual_trajectory = xy; % m
desired_trajectory = xy_d; % m

% RMS Joint Errors
RMS_error = rms(joint_errors);
% Max Joint Errors
max_error = max(abs(joint_errors));

% Plot Joint Errors vs Time
figure;
plot(time, joint_errors(:,1), 'b-');
hold on;
plot(time, joint_errors(:,2), 'r--');
hold on;
text(0.01,0.10,append('RMS Error = ', mat2str(RMS_error,3),' deg'), 'Units', 'normalized');
hold on;
text(0.01,0.05,append('Max Error = ', mat2str(max_error,3),' deg'), 'Units', 'normalized');
title(append('Joint Errors vs. Time for ', model_title));
xlabel('time (s)');
ylabel('error (deg)');
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

% If model_title is adaptive_control plot parameter adaptation
if strcmp(model_title, 'adaptive_control')
    figure;
    for i = 1:size(alpha, 2)
        plot(time, alpha(:,i));
        hold on;
    end
    title(append('Parameter Values vs. Time for ', model_title))
    xlabel('time (s)');
    ylabel('parameter value');
    legend('N1^2*Jm1 + I1 + m2*a1^2','r12*m2','r01*m1 + a1*m2','N2^2*Jm2 + I2');
end