function MM_splitTreadmill

% first read events
e = ReadNlynxEvents('Events.nev');

% now find all 0x0002
tmp = e.timestamps(e.port_status(:,2)==1);
goodevents = [tmp(1:7) tmp(10:end)];
oldevents = goodevents;

for i=1:length(goodevents)
    goodevents(i) = Nlynx_TimeStamp2Sample('1-CSC2.ncs', goodevents(i));
end

% Animal 1 - need files 1-CSC2.ncs (HPC) 1-CSC3.ncs (PFC)
% Animal 2 - need files 2-CSC2.ncs (HPC) 2-CSC3.ncs (PFC)

CSC1_2 = ReadCSC('1-CSC2.ncs');
CSC1_3 = ReadCSC('1-CSC3.ncs');
CSC2_2 = ReadCSC('2-CSC2.ncs');
CSC2_3 = ReadCSC('2-CSC3.ncs');

% cable, between TTLs, animal label, geno

% removed 1 [1 2] 'KO3' 'KO'; ...
data.subjects={2 [1 2] 'KO4' 'KO'; ...
    1 [3 4] 'KO7' 'KO'; ...
    2 [3 4] 'WT1' 'WT'; ...
    1 [5 6] 'WT2' 'WT'; ...
    2 [5 6] 'WT4' 'WT'; ...
    1 [7 8] 'KO1' 'KO'; ...
    1 [9 10] 'KO3' 'KO'};

clear tmp

for subjectidx=1:length(ex.subjects)
    tmp = ex.subjects{subjectidx,1};
%     sample = Nlynx_TimeStamp2Sample(cscfn, time)
    
    switch tmp
        case 1
            HPCdata = CSC1_2(goodevents(ex.subjects{subjectidx, 2}(1)):goodevents(ex.subjects{subjectidx, 2}(2)));
            PFCdata = CSC1_3(goodevents(ex.subjects{subjectidx, 2}(1)):goodevents(ex.subjects{subjectidx, 2}(2)));

        case 2
            HPCdata = CSC2_2(goodevents(ex.subjects{subjectidx, 2}(1)):goodevents(ex.subjects{subjectidx, 2}(2)));
            PFCdata = CSC2_3(goodevents(ex.subjects{subjectidx, 2}(1)):goodevents(ex.subjects{subjectidx, 2}(2)));

    end
    
    fnameHPC = [ex.subjects{subjectidx, 3} '_HPC.mat'];
    fnamePFC = [ex.subjects{subjectidx, 3} '_PFC.mat'];
    
    save(fnameHPC, 'HPCdata');
    save(fnamePFC, 'PFCdata');
    
end
