%% ME EN 6230 Lab 6 Ryan Dalby
% close all;
set(groot, 'DefaultTextInterpreter', 'none') % Prevents underscore from becoming subscript

% Note that for this lab the Forces block was renamed to forces and the
% output was changed to a structure with time

% Extract necessary data, will error if the data does not exist
time = forces.time; % s
model_title = extractBefore(forces.blockName, "/");
tracking_errors = (position_errors.signals.values)*1000; % mm
force_feedback = forces.signals.values; % N
    
% Plot Tracking Errors
figure;
plot(time, tracking_errors(:,1), 'b-');
hold on;
plot(time, tracking_errors(:,2), 'r--');
title(strcat("Tracking Errors vs. Time for ", model_title));
xlabel("time (s)");
ylabel("tracking error (mm)");
legend("x error", "y error");

% Plot Virtual Slave Force Feedback
figure;
plot(time, force_feedback(:,2), 'b-');
title(strcat("Virtual Slave Force Feedback vs. Time for ", model_title));
xlabel("time (s)");
ylabel("force (N)");
legend("Fy");


