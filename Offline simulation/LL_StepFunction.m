function [NextObs,Reward,IsDone,LoggedSignals] = LL_StepFunction(Action,LoggedSignals)
% Custom step function to construct 
%
% This function applies the given action to the environment and evaluates
% the system dynamics for one simulation step.


%% tranform action from cell to array
action_amplitude = Action(1);
action_pulsewidth = Action(2);

%% unpacking

%unpack models
Regression_intensity = LoggedSignals.ModelIntensity;
Regression_type = LoggedSignals.ModelType;
Regression_location = LoggedSignals.ModelLocation;

%unpack plot variable count
count = LoggedSignals.Count;
variables =  LoggedSignals.PlotVariables;

% Unpack the state vector from the logged signals.
State = LoggedSignals.State;
intensity = State(1);
type = State(2);
location = State(3);

%% Define the algorithm parameters
Parameters = LoggedSignals.Parameters;

A_currentIndex = Parameters(1);
PW_currentIndex = Parameters(2);

m = Parameters(3); %slope
q = Parameters(4); %intercept

%% Define action_amplitude and pulse width array
amplitudeArray = LoggedSignals.AmplitudeArray;
pulsewidthArray = LoggedSignals.PulsewidthArray;

%% Check if the given action is valid.
actionArray = {[1,1] , [1,0] , [1,-1] , [-1,1] , [-1,0] , [-1,-1] , [0,1] , [0,0] , [0,-1]};
actionArray = cell2mat(actionArray);
checkAmplitude = actionArray(1:2:end-1);
checkPulseWidth = actionArray(2:2:end);

if ismember(action_amplitude,checkAmplitude) == false || ismember(action_pulsewidth,checkPulseWidth) == false
          
type('Action selected is not consistent')
        
end
    
%% implement the action
 A_currentIndex =  A_currentIndex + action_amplitude;
 PW_currentIndex = PW_currentIndex + action_pulsewidth;

%action_amplitude currentIndex check
if A_currentIndex > length(amplitudeArray)
    A_currentIndex = length(amplitudeArray);
    
elseif A_currentIndex < 1 
    A_currentIndex = 1;
    
end
    
%action_pulsewidth currentIndex check
if PW_currentIndex > length(pulsewidthArray)
    PW_currentIndex = length(pulsewidthArray);
    
elseif PW_currentIndex < 1 
    PW_currentIndex = 1;   
end

%% apply action
amplitude = amplitudeArray(A_currentIndex);
pulsewidth = pulsewidthArray(PW_currentIndex);

%% define INTENSITY new state
Tintensity = table('Size',[1,3],'VariableTypes',["double","double","double"],'VariableNames',{'Charge','Slope','Intercept'});
Tintensity.Charge(1) = round(amplitude*pulsewidth);
Tintensity.Slope(1) = m;
Tintensity.Intercept(1) = q;

%classify intensity using regression model
intensity = Regression_intensity.predictFcn(Tintensity);

%intensity --> -1 not perceived; 0 good ; 1 high; 2 too high;
if intensity < 0
    
    intensity = -1;
    
elseif intensity > 0 && intensity < 0.5
    
    intensity = 0;
    
elseif intensity >= 0.5 && intensity <=1.2
    
    intensity = 1;
    
elseif intensity > 1.2
    
    intensity = 2;
    
end


%% Define TYPE new state --> classification (not regression)
Ttype= table('Size',[1,4],'VariableTypes',["double","double","double","double"],'VariableNames',{'Amplitude','PulseWidth','Slope','Intercept'});
Ttype.Amplitude(1) = amplitude;
Ttype.PulseWidth(1) = pulsewidth;
Ttype.Slope(1) = m;
Ttype.Intercept(1) = q;

%classify type using regression model
type = Regression_type.predictFcn(Ttype);

%% Define LOCATION new state
Tlocation= table('Size',[1,4],'VariableTypes',["double","double","double","double"],'VariableNames',{'Amplitude','PulseWidth','Slope','Intercept'});
Tlocation.Amplitude(1) = amplitude;
Tlocation.PulseWidth(1) = pulsewidth;
Tlocation.Slope(1) = m;
Tlocation.Intercept(1) = q;

%classify location using regression model
location = Regression_location.predictFcn(Tlocation);

%type --> 0 good location; 1 bad location ; -1 not perceived

if location <= 0.3
    
    location = 0;
    
else
    
    location = 1;
    
end

%% default values when intensity state is not perceived

if intensity == -1
    type = -1;
    location = -1;
end


%% update logged signals
% Transform state to observation.
LoggedSignals.State = [ intensity , type , location ];
NextObs = LoggedSignals.State;

%update the parameters
LoggedSignals.Parameters = [A_currentIndex ; PW_currentIndex ; m ; q];

%% Get a reward

%positive
if NextObs(1) == 0 && NextObs(2) == 0 && NextObs(3) == 0
    Reward = 15;
    
elseif NextObs(1) == 0 && NextObs(2) == 1 && NextObs(3) == 0
    Reward = 12;

elseif NextObs(1) == 0 && NextObs(2) == 0 && NextObs(3) == 1
    Reward = 11;
    
elseif NextObs(1) == 0 && NextObs(2) == 1 && NextObs(3) == 1
    Reward = 10;   
    
%less positive

elseif NextObs(1) == 1 && NextObs(2) == 0 && NextObs(3) == 0
    Reward = 4;
    
elseif NextObs(1) == 1 && NextObs(2) == 1 && NextObs(3) == 0
    Reward = 3;
    
elseif NextObs(1) == 1 && NextObs(2) == 0 && NextObs(3) == 1
    Reward = 2;
    
elseif NextObs(1) == 1 && NextObs(2) == 1 && NextObs(3) == 1
    Reward = 1; 
    

%not perceived --> less negative
elseif NextObs(1) == -1 && NextObs(2) == -1 && NextObs(3) == -1
    Reward = 0;
    

%negative    
elseif NextObs(1) == 2 && NextObs(2) == 0 && NextObs(3) == 0
    Reward = -1;
    
elseif NextObs(1) == 2 && NextObs(2) == 1 && NextObs(3) == 0
    Reward = -2;
    
elseif NextObs(1) == 2 && NextObs(2) == 0 && NextObs(3) == 1
    Reward = -3;
    
elseif NextObs(1) == 2 && NextObs(2) == 1 && NextObs(3) == 1
    Reward = -4; 
    
end


%% Update plot parameters and perform plot
%update plot parameter
count = count +1;
variables(1,count) = amplitude; 
variables(2,count) = pulsewidth; 
variables(3,count) = intensity; 
variables(4,count) = type; 
variables(5,count) = location; 
variables(6,count) = action_amplitude; 
variables(7,count) = action_pulsewidth;
variables(8,count) = Reward;
variables(9,count) = A_currentIndex;
variables(10,count) = PW_currentIndex;

LoggedSignals.Count = count;
LoggedSignals.PlotVariables =  variables; 

%% Terminal condition when the values are stable --> only for simulation
%if the values doesn't change for 5 consecutive values stop the simulation
n = 5;
if count > n 
    check_A = variables(9,end-n:end); 
    check_PW = variables(10,end-n:end); 
    
    %check they are equal
    if numel(unique(check_A))==1 && numel(unique(check_PW))==1
        IsDone = true;
        
    else
        IsDone = false;
    end
    
else
    IsDone = false;
end

%% perform plot
figure(1),
subplot(3,2,1),plot(1:count, variables(1,:),'--o'),title('Amplitude'),xlim([1,inf]);...
subplot(3,2,2),plot(1:count, variables(2,:),'--o'),title('Pulse Width'),xlim([1,inf]);...
subplot(3,2,3),plot(1:count, variables(3,:),'--o'),title('Intensity'),xlim([1,inf]),yticks([-1,0,1,2]),yticklabels(["NotPerceived","Low","High","Painful"]);...
subplot(3,2,4),plot(1:count, variables(4,:),'--o'),title('Type'),xlim([1,inf]),yticks([-1,0,1]),yticklabels(["NotPerceived","Pleasant","Unpleasant"]);...
subplot(3,2,5),plot(1:count, variables(5,:),'--o'),title('Location'),xlim([1,inf]),yticks([-1,0,1]),yticklabels(["NotPerceived","Somatotopic","NotSomatotopic"]);...
subplot(3,2,6),plot(1:count, variables(8,:),'--o'),title('Reward'),xlim([1,inf]);...
sgtitle('Low level simulation') 

if count == 200 || IsDone == true
    low_results = [amplitude , pulsewidth];
    save('LowResults','low_results');
end

end