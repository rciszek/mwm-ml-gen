# mwm-ml-gen
This program is the generalised version of mwm-ml (https://github.com/RodentDataAnalytics/mwm-ml). For more information on the experimental setups
and the procedures refer to the published paper http://www.nature.com/articles/srep14562.

## The Graphical User Interface (GUI)
The graphical user interface is split into two separate interfaces: the gui.m and the browse_trajectories.m. The first one is the main
interface where the user specifies the experimental setup and performs the segmentation and the classification process while the other
acts as a graphical tool for the labelling of the segments.

### gui.m
![GUI](gui.jpg?raw=true "GUI")

**Paths:**

• *Animal Groups:* must point to a csv files which contains animals ids and groups (example: data\mwm_peripubertal_stress\trajectory_groups.csv).

• *Trajectory Raw Data:* must point to a folder which contains the trajectory data (example: data\mwm_peripubertal_stress\).

• *Output Folder:* the folder in which the results will be saved.

**Experiment Settings:**

• *Sessions:* number of sessions

• *Trials per Session:* must be given in the following format: num1,num2,...,numN, where N = number of sessions.

• *Trial Types Description:* a name must be given as description.

• *Groups Description:* each animal group must have a unique description. For N animal groups, desc1,desc2,...descN must be given.

For the data provided these were the settings:

• *Sessions:* '3'

• *Trials per Session:* '4,4,4'

• *Trial Types Description:* 'Training'

• *Groups Description:* 'Control,Stress,Control/Food,Stress/Food'.

**Experiment Properties:**

• *Trial Timeout:* 90

• *Centre (X,Y):* 0 0

• *Arena Radius:* 100

• *Platform (X,Y):* -50 10

• *Platform Radius:* 6

• *Platform Proximity Radius:* 5

• *Longest Loop Extension:* 40

**Segmentation:**

According to the paper, three segmentation processes were performed:

• *Segment Length:* (a) 250 (b) 250 (c) 300

• *Segment Overlap:* (a) 0.9 (b) 0.7 (c) 0.7

**Segmentation:**
If all the above inputs are given (validation is performed and in case of error appropriate errormessage appears to the user),
the program loads the trajectory data, computes the specified features (see features) and performs the segmentation process.
All the results are stored inside a .mat file.

**Save Settings:**
Saves the above settings into a .mat file.

**Load Settings:**
Loads the above settings from a .mat file.

**Labelling and Classification:**

• *Labels:* must point to a csv file which contains labelled segments (see browse_trajectories.m, **Save Labels** button). Three of 
these files are provided inside the data\mwm_peripubertal_stress\ folder and they are (according to the experimental setup):
(a) segment_labels_250c.csv (b) segment_labels_250_70.csv (c) segment_labels_300_70.csv.

• *Segment Configurations:* must point to the .mat file generated from the segmentation process.

• *Number of Clusters:* (a) 75 (b) 35 (c) 37.

**Browse Trajectories:**

Loads the browse_trajectories gui. 

### browse_trajectories.m
![BROWSE](browse_trajectories.jpg?raw=true "BROWSE")

This file opens the interface which is used for the labelling of specific segments. It can be loaded by typing browse_trajectories or by clicking on 
the Browse Trajectories button of the gui.m.

First of all a segmentation configuation file (created from the segmentation process) must be given by clicking on the button
**Select Configuration File**. When the file is loaded, the user can see the arena with the whole trajectories as well as 
their segments. Below the arena the navigation panel allows the user to navigate to the previous (**<=**) or the 
next trajectory (**=>**) or specify which trajectory to be visualized by typing its id number and clicking **OK**.

The two tables on the upper left part of the window show various information about the selected trajectory and the
selected segment of the trajectory.

The **Segments** panel is used for manually labelling each of the segments. In order to label a segment this segment must be
selected from the list of segments and the desired label must be selected from the dropdown menu. Afterwards the button **+** must
be pressed. In order to remove a label from a segment the same process must be followed but afterwards the button **-** must
be pressed. Multiple labels can be assigned per segment and these assigned labels are shown on the square box.

The button **Save Labels** is used to save all the labelled segments and generates the csv file required for the classification process.

The button **Load Labels File** asks for a csv file which contains labelled segments, which is the one generated by the button **Save Labels**.

### Features

A complete list of the available features is shown inside the file *features_list.m*. This file can also be updated with user defined features.

### Labels

A complete list of the available labels is shown inside the file *tags_list.m*. This file can also be updated with user defined features.



