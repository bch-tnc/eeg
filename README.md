EEG Analysis Tools
- a project by Kenny Yau -

Current Project Objectives:
- optimize the data conversion flow (all the steps before applying the processing)

Future Project Objectives
- add analyses tools
- automate the data conversion process

Current Proposed Dataflow Design:
- record eeg data using neuroscore
- convert proprietary neuroscore chunks into non-proprietary .csv (or .txt) chunks using neuroscore
- stitch together .csv chunks into contiguous signals and save as .mat files using DSI_Load.m
- apply the filters that make sense to apply before the recording gets chopped up
- populate an Excel Sheet with the window times and durations of interest for each mouse
- using the above Excel Sheet, extract these windows of interest (WoI) with extractWindows.m
- apply any other filters necessary (none at the moment)
- calculate oscillation band power for each WoI and save data to Excel spreadsheet

Steps to Run this Analyses:
(skipping the neuroscore-dependent operations)
- run DSI_Load
- populate .xlsx w/ windows of interest (WoI)
- run prefilter.m (not implemented yet)
- run extractWindows.m
- run plots.m (can skip if don't need )
- run outputPower.m

After all of this, the result should be a .csv file with the power band values

At this moment, running DSI_Load.m, extractWindows.m, and outputPower.m works pretty smoothly