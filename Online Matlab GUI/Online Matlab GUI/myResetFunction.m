function [InitialObservation, LoggedSignals] = myResetFunction(slope,intercept)
% Reset function 

%% load models to simulate the patient's answers
load intensity_model
load type_model
load location_model

%% Da settare : set slope and intercept 
values = xlsread('TotalValues.xls');

%choose the patient randomly
% lines = values(:,3:4);
% index=randi(size(lines,1));
% slope=lines(index,1);
% intercept=lines(index,2);

%define amplitude and charge array
amplitudes = values(:,1);
pulsewidths = values(:,2);

amplitudeArray = [ min(amplitudes) : 1 : max(amplitudes) ];
pulsewidthArray = [ min(pulsewidths) : 10 : max(pulsewidths) ];

%% set initial state

% set Initial state %default value --> not perceived
intensity = -1;
type = -1;
location = -1;

%set initial index for amplitude and pulse width arrays --> default value = first index 
A_initialIndex = 1; %set the initial index for amplitude
PW_initialIndex = 1; %set the initial index for pulse width

%% update LoggedSignals to transfer the information to the Reset Function
% Return initial environment state variables as logged signals.
LoggedSignals.State = [ intensity , type , location];
InitialObservation = LoggedSignals.State;

%% Use Logged signal to transfer parameters information
LoggedSignals.Parameters = [A_initialIndex ; PW_initialIndex ; slope ; intercept];

%save variables for plot 
count = 0; 
variables = []; %1 row --> amplitude    %4 row --> type             %7 row --> pulsewidth action %10 row --> PW_index  
                %2 row --> pulse width  %5 row --> location         %8 row --> reward          
                %3 row --> intensity    %6 row --> amplitude action %9 row --> A_index              
                
              
LoggedSignals.Count = count;
LoggedSignals.PlotVariables = variables;
LoggedSignals.ModelIntensity = Regression_intensity;
LoggedSignals.ModelType = Regression_type;
LoggedSignals.ModelLocation = Regression_location;
LoggedSignals.AmplitudeArray = amplitudeArray;
LoggedSignals.PulsewidthArray = pulsewidthArray;

end
