# Automated calibration of somatosensory nerve stimulation using reinforcement learning


The folder *offline simulation* contains the code to run 10 different offline simulations. The code
is entirely commented to make it user-friendly. Choose the subject number from 1 to 10 at the top
of the Main.m file and then press "Run" sto start the simulation for low and high levels. Two plots 
will show the simulation steps. At the end of the simulation the final stimulation parameters will be
shown on the Matlab command window.

**Requirements:** 

[Reinforcement Learning toolbox](https://ch.mathworks.com/products/reinforcement-learning.html)

Version used: Matlab R2020b


The folder *online Matlab GUI* contains the first version of the GUI used for online experiments.
As the GUI used for the experiments is based on a UDP protocol for the connection with Unity 3D 
that version would not be useful to share. The absence of connection with Unity make that GUI not 
suitable for testing.The purpose of sharing this GUI is therefore to make people aware of the 
application of the designed RL learning agents and how they have been used. The GUI will show how 
stimulation parameters will be updated based on the sensory feedback. Connection with the TENS device
is not implemented. No maximum iteration check is set. No Data saving is implemented. 

**Requirements:** 

[Reinforcement Learning toolbox](https://ch.mathworks.com/products/reinforcement-learning.html) 

[Classification Learner toolbox](https://ch.mathworks.com/help/stats/classificationlearner-app.html)

[Regression Learner toolbox](https://ch.mathworks.com/help/stats/regression-learner-app.html)

Version used: Matlab R2020b

To run the GUI and visualize the code:

- Open matlab and go to the corresponding director
- Open app1.mplapp from Matlab folder view
- On the top right corner select "Code view" to visualize the code
- Press "Run" from the top left corner to start the GUI instead.
- Choose the settings from the left pannel. Use "Insert starting values option" for manual 
  initialization. Start with the low level.

- Press start
- Provide the feedback by pressing the intensity / type / sens under electrodes and location of 
  sensation buttons. 
- Press next to feed the agent with the feedback and receive the updated parameters 
- Repeat the process as long as you want. No stopping condition are present in this testing GUI
- Press stop to complete the low level characterization. Left and right panel will be reset.
- A window pop-up will suggest the high level parameters. Write down these parameters.
- Repeat the process choosing the High level option on the left panel.
- Use the "Insert starting values" option to insert the priously suggested high level parameters.
- Repeat the process and then press the Stop button to complete.
- A window pop-up will inform that characterization is completed.
