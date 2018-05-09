# EEG Analysis Tools
- a project by Kenny Yau
- last updated: 09-May-2018

## Urgent Project Objectives:
- format the way savePowerRatio saves the power values
- saving averaged power band values
- watch program's memory usage doesn't crash the system (currently can use around 13GB for 4 mice's worth of data)

### Medium Priority Objectives:
- use a periodogram instead of an fft in the power band value calculations (around line 40 in calcPowerRatios)

### Lower Priority Objectives:
- add column for subwindow number

### Future Project Objectives
- have calcGroupAvg.m read in a list of window/genotype combinations to average
- have DSI_Load.m run for multiple folders
- add analyses tools
- automate the data conversion process
- add treatment type as a parameter
- pinpoint the peak frequency within a power band (Alex's suggestion)

## Current Dataflow Design:
- define window types in winDefs.xlsx
- populate WOI.xlsx
- record eeg data
- run DSI_Load.m
- run extractWindows.m
- run calcGroupAvg.m

### After all of this, the result should be:
- a .mat file called "expData.mat" which contains a struct containing all trace window data for a single experiment
- a .csv file called "powerData.csv" with the power band values
- a vector of power band averages for the windows you specify gets printed out

# Changelog (in chronological order)
- At this moment, running DSI_Load.m, extractWindows.m, and outputPower.m works pretty smoothly.
- DSI_Load.m saves traces 2 directories above text files (on the same level where subexperiment folders are)
- Power values may not be calculated correctly
- calcGroupAvg.m works too, but it only checks for window type and genotype, not treatment. 
- Subwindows are no longer saved; only the parent trace is saved
- Power values are saved within the expData struct under the powerRatios field
- Subwindow power band values are also calculated
- The first row of the powerRatios field is power band values for the parent window; subsequent rows are that of subwindows
- calcPowerRatios no longer saves power values; that functionality is left to savePowerRatios
- Changed "window number" to "window type" for clarity between window type and subwindow number
- Prints status messages outside of functions
- Power ratio values are nicely formatted now