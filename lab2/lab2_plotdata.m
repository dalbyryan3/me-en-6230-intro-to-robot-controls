%% ME EN 6230    Lab 2 Plot Joint Error and Trajectory    Ryan Dalby
set(groot, "DefaultTextInterpreter", "none") % Prevents underscore from becoming subscript

% Extract necessary data, will error if the data does not exist
time = errors.time; % s
time_datapoints = length(time);
model_title = extractBefore(errors.blockName, "/errors");
joint_errors = rad2deg(transpose(reshape(errors.signals.values, [2, time_datapoints]))); % deg
actual_trajectory = xy; % m
desired_trajectory = xy_d; % m

% RMS Joint Errors
RMS_error = rms(joint_errors);
% Max Joint Errors
max_error = max(abs(joint_errors));

% Plot Joint Errors vs Time
figure;
plot(time, joint_errors(:,1), "b-");
hold on;
plot(time, joint_errors(:,2), "r--");
hold on;
rms_string = mat2str(RMS_error,3);
text(0.01,0.10,strcat("RMS Error = ", rms_string," deg"), "Units", "normalized");
hold on;
max_string = mat2str(max_error,3);
text(0.01,0.05,strcat("Max Error = ", max_string," deg"), "Units", "normalized");
title(strcat("Joint Errors vs. Time for ", model_title));
xlabel("time (s)");
ylabel("error (deg)");
legend("joint 1", "joint 2");

% Plot End-Effector Trajectory
figure;
plot(xy(:,1), xy(:,2), "b-");
hold on;
plot(xy_d(:,1), xy_d(:,2), "r--");
title(strcat("End-Effector Trajectory for ", model_title));
xlabel("x (m)");
ylabel("y (m)");
legend("actual", "desired");

% If model_title is adaptive_control plot parameter adaptation
if strcmp(model_title, "lab2_adaptive_control")
    figure;
    for i = 1:size(alpha, 2)
        plot(time, alpha(:,i));
        hold on;
    end
    title(strcat("Parameter Values vs. Time for ", model_title))
    xlabel("time (s)");
    ylabel("parameter value");
    legend("N1^2*Jm1 + I1 + m2*a1^2","r12*m2","r01*m1 + a1*m2","N2^2*Jm2 + I2");
end
