%% ME EN 6230 Problem Set 5 Ryan Dalby
%%
close all;
%% System Description
Gp = tf(.539, [0.004015 0.01519 0.067]);
PD = tf([0.27 14.21], 1);
PID = tf([7.67 372.76 4529.06], [1 0]);

%% 
% Send data for PD controller to workspace, then execute this cell
PD_step_response_data = out.ScopeData;
%% 
% Send data for PID controller to workspace, then execute this cell
PID_step_response_data = out.ScopeData;
%% 
% Send data for PV controller to workspace, then execute this cell
PV_step_response_data = out.ScopeData;
%% 
% Send data for PIV controller to workspace, then execute this cell
PIV_step_response_data = out.ScopeData;

%% 
% Send data for PD controller with disturbance to workspace, then execute this cell
PDdist_step_response_data = out.ScopeData;
%% 
% Send data for PID controller with disturbance to workspace, then execute this cell
PIDdist_step_response_data = out.ScopeData;
%% 
% Send data for PV controller with disturbance to workspace, then execute this cell
PVdist_step_response_data = out.ScopeData;
%% 
% Send data for PIV controller with distrubance to workspace, then execute this cell
PIVdist_step_response_data = out.ScopeData;
%% Problem 3
% PD plot
figure;
plot(PD_step_response_data(:,1), PD_step_response_data(:,2));
xlabel('Time (s)');
ylabel('Theta (rad)');
title('PD Controller Step Response');
annotation('textbox',...
    [0.251 0.823809523809524 0.206142857142857 0.0595238095238098],...
    'String',{'~45% overshoot'},...
    'FitBoxToText','off');
annotation('textbox',...
    [0.493857142857142 0.564285714285717 0.216857142857143 0.0595238095238098],...
    'String','~0.2s settling time',...
    'FitBoxToText','off');
annotation('textbox',...
    [0.55 0.673809523809525 0.332142857142857 0.0581812787420278],...
    'String','~0.009 rad steady state error',...
    'FitBoxToText','off');

% PID plot
figure;
plot(PID_step_response_data(:,1), PID_step_response_data(:,2));
xlabel('Time (s)');
ylabel('Theta (rad)');
title('PID Controller Step Response');
annotation('textbox',...
    [0.168857142857143 0.811904761904762 0.2065 0.0666666666666675],...
    'String','~78% overshoot',...
    'FitBoxToText','off');
annotation('textbox',...
    [0.381357142857142 0.598571428571431 0.232928571428572 0.0666666666666674],...
    'String','~0.15s settling time',...
    'FitBoxToText','off');
annotation('textbox',...
    [0.55 0.473809523809525 0.332142857142857 0.0581812787420278],...
    'String','~0.0 rad steady state error',...
    'FitBoxToText','off');
%% Problem 4
% Closed loop poles of PID system (these are not exactly the desired poles
% since our assumptions of a second order system are not accurately valid,
% there is interference from the third closed loop pole and two closed loop
% zeroes. Will compare this value to PIV closed loop zeroes
disp(pole(feedback(Gp*PID,1)));

% PV plot
figure;
plot(PV_step_response_data(:,1), PV_step_response_data(:,2));
xlabel('Time (s)');
ylabel('Theta (rad)');
title('PV Controller Step Response');
annotation('textbox',...
    [0.327785714285714 0.842857142857144 0.200785714285714 0.061904761904763],...
    'String',{'~19% overshoot'},...
    'FitBoxToText','off');
annotation('textbox',...
    [0.499214285714285 0.702380952380956 0.218642857142858 0.061904761904763],...
    'String','~0.2s settling time',...
    'FitBoxToText','off');
annotation('textbox',...
    [0.55 0.803809523809525 0.332142857142857 0.0581812787420278],...
    'String','~0.009 rad steady state error',...
    'FitBoxToText','off');

% PIV plot
figure;
plot(PIV_step_response_data(:,1), PIV_step_response_data(:,2));
xlabel('Time (s)');
ylabel('Theta (rad)');
title('PIV Controller Step Response');
annotation('textbox',...
    [0.380285714285714 0.840476190476191 0.202571428571429 0.0547619047619079],...
    'String',{'~14% overshoot'},...
    'FitBoxToText','off');
annotation('textbox',...
    [0.470642857142857 0.721428571428572 0.222214285714286 0.0523809523809583],...
    'String','~0.2s settling time',...
    'FitBoxToText','off');
annotation('textbox',...
    [0.587 0.82 0.312142857142857 0.0581812787420278],...
    'String','~0.0 rad steady state error',...
    'FitBoxToText','off');

%% Problem 5
figure;
plot(PDdist_step_response_data(:,1), PDdist_step_response_data(:,2));
hold on;
plot(PIDdist_step_response_data(:,1), PIDdist_step_response_data(:,2));
hold on;
plot(PVdist_step_response_data(:,1), PVdist_step_response_data(:,2));
hold on;
plot(PIVdist_step_response_data(:,1), PIVdist_step_response_data(:,2));
hold on;
legend('PD controller', 'PID controller', 'PV controller', 'PIV controller');
xlabel('Time (s)');
ylabel('Theta (rad)');
title('Comparison of Controller Step Response with a Disturbance of 5');
