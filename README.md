EEG Analysis Tools
- a project by Kenny Yau
- last updated: 28-Mar-2018

Current Project Objectives:
- decide how to save subwindows
- polish the features we currently have

Future Project Objectives
- add analyses tools
- automate the data conversion process
- add treatment type as a parameter
- average the entire FFT for multiple mice of the same genotype
- use a periodogram instead of an fft in the power band value calculations
- pinpoint the peak frequency within a power band (Alex's suggestion)

Current Dataflow Design:
- record eeg data using neuroscore
- convert proprietary neuroscore chunks into non-proprietary .csv (or .txt) chunks using neuroscore
- stitch together .csv chunks into contiguous signals and save as .mat files using DSI_Load.m
- apply the filters that make sense to apply before the recording gets chopped up
- define window types in windowDefinition.xlsx
- populate WOI.xlsx with the window types and start times of interest for each mouse
- using the above Excel Sheet, extract these windows of interest (WoI) with extractWindows.m
- apply any other filters necessary (none at the moment)
- calculate oscillation band power for each WoI and save data to Excel spreadsheet

Current Proposed Dataflow Design:
- record eeg data using neuroscore
- convert proprietary neuroscore chunks into non-proprietary .csv (or .txt) chunks using neuroscore
- stitch together .csv chunks into contiguous signals and save as .mat files using DSI_Load.m
- apply the filters that make sense to apply before the recording gets chopped up
- define window types in windowDefinition.xlsx
- populate WOI.xlsx with the window types and start times of interest for each mouse
- apply any other filters necessary (none at the moment)
- calculate oscillation band power for each WoI and save data to Excel spreadsheet
- run a script to average the power band values we are interested in

Steps to Run this Analyses:
(skipping the neuroscore-dependent operations)
- run DSI_Load
- check correct window definitions exist in windowDefinition.xlsx
- populate .xlsx w/ windows of interest (WoI)
- run prefilter.m (not implemented yet)
- run extractWindows.m
- run plots.m (can skip if don't need )
- run outputPower.m
- run calcGroupAvg.m

After all of this, the result should be:
	- a .csv file with the power band values
	- a .mat file called "expData.mat" which contains a struct containing all trace window data for a single experiment
	- a vector of power band averages for the windows you specify gets printed out

At this moment, running DSI_Load.m, extractWindows.m, and outputPower.m works pretty smoothly. calcGroupAvg.m works too
but it only checks for window type and genotype, not treatment. Subwindows are currently not saved in a nice struct; 
each subwindow gets saved in its own .mat file.