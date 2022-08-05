function [InitialObservation, LoggedSignals] = HL_ResetFunction(slope,intercept,startingAmplitude,startingPulseWidth)
% Reset function 

%% load models to simulate the patient's answers
load intensity_model
load type_model
load location_model
%% Starting values

A = startingAmplitude;
PW = startingPulseWidth;

%% define array values
amplitudeArray = 1:16;
pulsewidthArray = 70:10:600;


%% set initial state
%default value --> not perceived
intensity = -1;
type = -1;
location = -1;

%set initial index for amplitude and pulse width arrays 
A_initialIndex = find(amplitudeArray == A); 
PW_initialIndex = find(pulsewidthArray == PW); 

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
