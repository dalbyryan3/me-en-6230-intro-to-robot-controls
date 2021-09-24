%% ME EN 6230 Problem Set 10 Ryan Dalby
% close all;
set(groot, 'DefaultTextInterpreter', 'none') % Prevents underscore from becoming subscript

% Extract necessary data, will error if the data does not exist
time = xy_errors.time; % s
model_title = extractBefore(xy_errors.blockName, "/");
actual_trajectory = xy; % m
desired_trajectory = xy_d; % m
opspace_errors = xy_errors.signals.values*1000; % mm
forces = F.signals.values; % N
force_errors = F_errors.signals.values; % N
    
% Plot End-Effector Trajectory
figure;
plot(time, xy(:,1), 'b-');
hold on;
plot(time, xy_d(:,1), 'r--');
title(strcat("End-Effector Trajectory vs. Time for ", model_title));
xlabel("time (s)");
ylabel("x (m)");
legend("actual", "desired");

% Plot Operational Space Errors
figure;
plot(time, opspace_errors(:,1), 'b-');
hold on;
plot(time, opspace_errors(:,2), 'r--');
title(strcat("Operational Space Errors vs. Time for ", model_title));
xlabel("time (s)");
ylabel("operational space error (mm)");
legend("x error", "y error");


% Plot End-Effector Forces 
figure;
plot(time, forces(:,1), 'b-');
hold on;
plot(time, forces(:,2), 'r-');
title(strcat("End-Effector Forces vs. Time for ", model_title));
xlabel("time (s)");
ylabel("forces (N)");
legend("Fx", "Fy");

% Plot Force Errors
figure;
plot(time, force_errors(:,1), 'b-');
hold on;
plot(time, force_errors(:,2), 'r-');
title(strcat("Force Errors vs. Time for ", model_title));
xlabel("time (s)");
ylabel("force errors (N)");
legend("Fx error", "Fy error");

