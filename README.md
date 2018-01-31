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
- apply the filters that make sense to apply when the signal is contiguous to the data
- populate an Excel Sheet with the window times and durations of interest for each mouse
- using the above Excel Sheet, extract these windows of interest with extractWindows.m

Steps to Run this Analyses:
(skipping the neuroscore-dependent operations)
- run DSI_Load
- populate .xlsx w/ windows of interest (WoI)
- run extractWindows.m