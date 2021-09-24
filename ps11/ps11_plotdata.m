%% ME EN 6230 Problem Set 11 Ryan Dalby
% close all;
set(groot, 'DefaultTextInterpreter', 'none') % Prevents underscore from becoming subscript

% Extract necessary data, will error if the data does not exist
time = xy_errors.time; % s
model_title = extractBefore(xy_errors.blockName, "/");
position = xy; % m (Note: xy sequentially contains: x, y, xrel, yrel)
desired_position = xy_d; % m
position_errors = xy_errors.signals.values*1000; % mm
internal_forces = F.signals.values; % N
internal_forces_errors = ForceErrors.signals.values; % N

% Plot Position of Block (Robot 1 Pinned End-Effector)
figure;
plot(position(:,1), position(:,2), 'b-');
hold on;
plot(desired_position(:,1), desired_position(:,2), 'r--');
title(strcat("Robot 1 End-Effector Position for ", model_title));
xlabel("x (m)");
ylabel("y (m)");
legend("actual", "desired");

% Plot Position Errors of Block (Robot 1 Pinned End-Effector)
figure;
plot(time, position_errors(:,1), 'b-');
hold on;
plot(time, position_errors(:,2), 'r--');
title(strcat("Robot 1 End-Effector Errors vs. Time for ", model_title));
xlabel("time (s)");
ylabel("position errors (mm)");
legend("x error", "y error");

% Plot Internal Forces
figure;
plot(time, internal_forces(:,1), 'b-');
hold on;
plot(time, internal_forces(:,2), 'r-');
title(strcat("Internal Forces vs. Time for ", model_title));
xlabel("time (s)");
ylabel("internal forces (N)");
legend("Fintx", "Finty");

% Plot Internal Force Errors
figure;
plot(time, internal_forces_errors(:,1), 'b-');
hold on;
plot(time, internal_forces_errors(:,2), 'r-');
title(strcat("Internal Force Errors vs. Time for ", model_title));
xlabel("time (s)");
ylabel("internal force errors (N)");
legend("Fintx error", "Finty error");

