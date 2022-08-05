clear all
close all
clc

%% choose subject simulation
nSubject = 10; % from 1 to 10
sbjMatrix = [0.00625 , -3; ...
             0.00740 , -4.67; ...
             0.00451 , -0.526; ...
             0.00682 , -6.25 ; ...
             0.00779 , -7.43; ...
             0.00833 , -8.5; ...
             0.01000 , -11; ...
             0.00779 , -7.43; ...
             0.00857 , -8.80; ...
             0.00667 , -6;];
             

%% observations definition

% [intensity , type , location]

%intensity --> -1 not perceived ; 0 low ; 1 high ; 2 too high

%type --> 0 pleasant ; 1 unpleasant ; -1 not perceived

%location --> 0 somatotopic  location ; not somatotopic ; 
              %-1 not perceived

%discrete observations
obsInfo = rlFiniteSetSpec({[0,0,0],[0,1,0],[0,0,1],[0,1,1],...
                           [1,0,0],[1,1,0],[1,0,1],[1,1,1],...
                           [-1,-1,-1],...
                           [2,0,0],[2,1,0],[2,0,1],[2,1,1]});

obsInfo.Name = 'observations';
obsInfo.Description = 'intensity,type,location';
numObservations = obsInfo.Dimension(2);

%% actions definition

% 1 increase ; 0 equal ; -1 decrease

%[ A , PW] --> all the possible combinations 


actInfo = rlFiniteSetSpec({ [1,1] , [1,0] , [1,-1] , ...
                            [-1,1] , [-1,0] , [-1,-1] , ...
                            [0,1] , [0,0] , [0,-1]});

actInfo.Name = 'values changes';
numActions = numel(actInfo.Elements);


%% load agents
load 'agent1.mat';
lowAgent = agent;

load 'agent3.mat';
highAgent = agent;


%% build low-level environments
slope = sbjMatrix(nSubject,1);
intercept = sbjMatrix(nSubject,2);

LL_ResetHandle = @()LL_ResetFunction(slope,intercept);
LL_env = rlFunctionEnv(obsInfo,actInfo,'LL_StepFunction',LL_ResetHandle);

%Fix the random generator seed for reproducibility
rng(0);

%% low level simulation
simOptions = rlSimulationOptions('MaxSteps',200);
simOptions.NumSimulations = 1;  
experience = sim(LL_env,lowAgent,simOptions);


%% regression high level
load LowResults
load TotalValues
amplitudeLow = low_results(1);
pulsewidthLow = low_results(2);
chargeLow = amplitudeLow * pulsewidthLow;
charge_position = find (matrice(1:2:(end-1),3) == chargeLow);
amplitude_dataset = matrice(charge_position*2-1,1);
pulsewidth_dataset = matrice(charge_position*2,2);
possible_position = find(amplitude_dataset == amplitudeLow);

if ~isempty(possible_position)
	newPulsewidth = pulsewidth_dataset(possible_position);
	pulsewidthHigh = min(newPulsewidth);
                   
	if pulsewidthHigh > pulsewidthLow
    	startingPulseWidth = pulsewidthHigh;
        startingAmplitude = amplitudeLow; 
    end
    
else
        startingAmplitude = amplitudeLow;
        startingPulseWidth = pulsewidthLow; 
end

%% build high-level environments
slope = sbjMatrix(nSubject,1);
intercept = sbjMatrix(nSubject,2);

HL_ResetHandle = @()HL_ResetFunction(slope,intercept,startingAmplitude,startingPulseWidth);
HL_env = rlFunctionEnv(obsInfo,actInfo,'HL_StepFunction',HL_ResetHandle);

%Fix the random generator seed for reproducibility
rng(0);

%% high level simulation
simOptions = rlSimulationOptions('MaxSteps',200);
simOptions.NumSimulations = 1;  
experience = sim(HL_env,highAgent,simOptions);

%% plot results
load HighResults
T = table('Size',[1,4],'VariableTypes',["double","double","double","double"],'VariableNames',{'LowAmplitude','LowPulseWidth','HighAmplitude','HighPulseWidth'});
T.LowAmplitude = low_results(1);
T.LowPulseWidth = low_results(2);
T.HighAmplitude = high_results(1);
T.HighPulseWidth = high_results(2);
T


