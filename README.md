EEG Analysis Tools
- a project by Kenny Yau
- last updated: 25-Apr-2018

Urgent Project Objectives:
- confirm savePowerRatios saves the power band values just as well as calcPowerRatios does
- add column for subwindow number
- averaging power band values by drug treatment type, genotype, etc (don't recalculate power ratios)
- add an isPlotted boolean to control graph output
- watch program's memory usage doesn't crash the system (currently can use ~13GB for 4 mice's worth of data)

Lower Priority Objectives:
- consider changing window number to window type 
- use a periodogram instead of an fft in the power band value calculations

Future Project Objectives
- have DSI_Load.m run for multiple folders
- add analyses tools
- automate the data conversion process
- add treatment type as a parameter
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

After all of this, the result should be:
	- a .mat file called "expData.mat" which contains a struct containing all trace window data for a single experiment
	- a .csv file with the power band values
	- a vector of power band averages for the windows you specify gets printed out

At this moment, running DSI_Load.m, extractWindows.m, and outputPower.m works pretty smoothly.
DSI_Load.m saves traces 2 directories above text files (on the same level where subexperiment folders are)
Power values are calculated correctly
calcGroupAvg.m works too, but it only checks for window type and genotype, not treatment. 
Subwindows are no longer saved; only the parent trace is saved
Power values are saved within the expData struct under the powerRatios field
Subwindow power band values are also calculated
The first row of the powerRatios field is power band values for the parent window; subsequent rows are that of subwindows