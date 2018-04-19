EEG Analysis Tools
- a project by Kenny Yau
- last updated: 18-Apr-2018

Current Project Objectives:
- save .mat files in the root directory
- polish the features we currently have, e.g.
	- calculate power band values for each subwindow
	- use a periodogram instead of an fft in the power band value calculations
	- averaging power band values by drug treatment type, genotype, etc
- combine extractWindows.m and outputPower.m so that we don't have to save each subwindow

Future Project Objectives
- add analyses tools
- automate the data conversion process
- add treatment type as a parameter
- average the entire FFT for multiple mice of the same genotype
- pinpoint the peak frequency within a power band (Alex's suggestion)

Current Dataflow Design:
- define window types in winDefs.xlsx
- populate WOI.xlsx
- record eeg data
- run DSI_Load.m
- run extractWindows.m
- run outputPower.m

What This Does:
- defines window types in winDefs.xlsx
- populates WOI.xlsx with the window types and their start times for each mouse
- records eeg data using neuroscore
- converts proprietary neuroscore chunks into non-proprietary .csv (or .txt) chunks using neuroscore
- stitches together .csv chunks into contiguous signals and save as .mat files using DSI_Load.m
- using the above Excel Sheet, extracts these windows of interest (WoI) with extractWindows.m
- calculates oscillation band power for each WoI and saves data to an Excel spreadsheet

Current Proposed Dataflow Design:
- define window types in windowDefinition.xlsx
- populate WOI.xlsx with the window types and start times of interest for each mouse
- record eeg data using neuroscore
- convert proprietary neuroscore chunks into non-proprietary .csv (or .txt) chunks using neuroscore
- stitch together .csv chunks into contiguous signals and save as .mat files using DSI_Load.m
- apply the filters that make sense to apply before the recording gets chopped up
- using the above Excel Sheet, extracts these windows of interest (WoI) with extractWindows.m
- apply any other filters necessary (none at the moment)
- calculate oscillation band power for each WoI and save data to Excel spreadsheet
- run a script to average the power band values we are interested in

After all of this, the result should be:
	- a .mat file called "expData.mat" which contains a struct containing all trace window data for a single experiment
	- a .csv file with the power band values
	- a vector of power band averages for the windows you specify gets printed out

At this moment, running DSI_Load.m, extractWindows.m, and outputPower.m works pretty smoothly.
Power values are calculated correctly
calcGroupAvg.m works too, but it only checks for window type and genotype, not treatment. 
Subwindows are currently not saved in a nice struct; each subwindow gets saved in its own .mat file.
Power values are saved within the expData struct.