%% ME EN 6230 Lab 5 Ryan Dalby
% close all;
set(groot, 'DefaultTextInterpreter', 'none') % Prevents underscore from becoming subscript

% Do note that for this lab the XYErrors and ForceErrors were changed from
% outputting as a dataset to outputting as a structure with time and a block
% to output xy_d was added when compared to Lab5_template2021.slx

% Extract necessary data, will error if the data does not exist
time = XYErrors.time; % s
model_title = extractBefore(XYErrors.blockName, "/");
actual_trajectory = xy; % m
desired_trajectory = xy_d; % m
tracking_errors = XYErrors.signals.values*1000; % mm
forces = F(:,2:3); % N
force_errors = ForceErrors.signals.values; % N
    
% Plot End-Effector X-Position
figure;
plot(time, xy(:,1), 'b-');
hold on;
plot(time, xy_d(:,1), 'r--');
title(strcat("End-Effector X-Position vs. Time for ", model_title));
xlabel("time (s)");
ylabel("x (m)");
legend("actual", "desired");

% Plot Tracking Errors
figure;
plot(time, tracking_errors(:,1), 'b-');
hold on;
plot(time, tracking_errors(:,2), 'r--');
title(strcat("Tracking Errors vs. Time for ", model_title));
xlabel("time (s)");
ylabel("tracking error (mm)");
legend("x error", "y error");


% Plot Y-Force
figure;
plot(time, forces(:,2), 'r-');
title(strcat("Y-Force vs. Time for ", model_title));
xlabel("time (s)");
ylabel("y-force (N)");
legend("Fy");


% Plot Y-Force Error
figure;
plot(time, force_errors(:,2), 'r-');
title(strcat("Y-Force Errors vs. Time for ", model_title));
xlabel("time (s)");
ylabel("y-force errors (N)");
legend("Fy error");


