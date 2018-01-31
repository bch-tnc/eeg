ex.rootfolder={'Volumes/Meera/Treadmill Data/2014-12-23_12-27-06'};
ex.hdr=nlynxhdr2mat('CSC1.ncs');
%Column meaning:
%1: subject order 3: cable 2:TTL limiters 4:subject 5:genotype
ex.subjects={1 1 [1 2] 'KO3' 'KO'
    1 2 [1 2] 'KO4' 'KO'
    2 1 [2 3] 'KO7' 'KO'
    2 2 [2 3] 'WT1' 'WT'
    3 1 [3 4] 'WT2' 'WT'
    3 2 [3 4] 'WT4' 'WT'
    4 1 [4 5] 'KO1' 'KO'
    5 1 [8 9] 'KO3' 'KO'}