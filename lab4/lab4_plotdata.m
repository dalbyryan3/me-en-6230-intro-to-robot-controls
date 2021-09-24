%% ME EN 6230 Lab 4 Ryan Dalby
% close all;
set(groot, 'DefaultTextInterpreter', 'none') % Prevents underscore from becoming subscript

% Extract necessary data, will error if the data does not exist
time = xy_errors.time; % s
model_title = extractBefore(xy_errors.blockName, "/");
actual_trajectory = xy; % m
desired_trajectory = xy_d; % m
opspace_errors = xy_errors.signals.values; % m
forces = F(:,2:3); % N

% Plot End-Effector X-Y Trajectory
figure;
plot(xy(:,1), xy(:,2), 'b-');
hold on;
plot(xy_d(:,1), xy_d(:,2), 'r--');
title(strcat("End-Effector Trajectory for ", model_title));
xlabel("x (m)");
ylabel("y (m)");
legend("actual", "desired");

% Plot Operational Space Errors vs Time
figure;
plot(time, opspace_errors(:,1), 'b-');
hold on;
plot(time, opspace_errors(:,2), 'r-');
title(strcat("Operational Space Errors vs. Time for ", model_title));
xlabel("time (s)");
ylabel("error (m)");
legend("x error", "y error");

% Plot End-Effector Forces vs Time
figure;
plot(time, forces(:,1), 'b-');
hold on;
plot(time, forces(:,2), 'r-');
title(strcat("End-Effector Forces vs. Time for ", model_title));
xlabel("time (s)");
ylabel("forces (N)");
legend("Fx", "Fy");

