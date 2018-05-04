addpath(genpath('D:\CODE\GitHub\KiloSort')) % path to kilosort folder
addpath('D:\CODE\GitHub\FwBwAddon')
addpath('D:\CODE\GitHub\npy-matlab')

% mexcuda('D:\CODE\GitHub\FwBwAddon\mexClustering.cu');

pathToYourConfigFile = 'D:\CODE\GitHub\FwBwAddon'; % take from Github folder and put it somewhere else (together with the master_file)
run(fullfile(pathToYourConfigFile, 'configFileBench384.m'))

% common options for every probe
ops.chanMap     = 'D:\CODE\GitHub\FwBwAddon\neuropixPhase3A_kilosortChanMap_385.mat';
% ops.trange      = [3300 Inf]; % TIME RANGE IN SECONDS TO PROCESS
% ops.trange      = [3400 Inf]; % TIME RANGE IN SECONDS TO PROCESS
ops.trange      = [3750 Inf]; % TIME RANGE IN SECONDS TO PROCESS

ops.Nfilt       = 512; % how many clusters to use
ops.nfullpasses = 6; % how many forward backward passes to do
ops.nPCs        = 7; % how many PCs to project the spikes into

ops.useRAM      = 0; % whether to use RAM for all data, or no data
ops.spkTh       = -4; % spike threshold
ops.nSkipCov    = 5; % how many batches to skip when computing whitening matrix

probeName = {'K1', 'K2', 'K3', 'ZNP1', 'ZNP2', 'ZNP3', 'ZNP4', 'ZO'};
mname = 'Krebs'; %'Waksman'; %'Krebs'; %'Robbins';
datexp = '2017-06-05'; %'2017-06-10'; %'2017-06-13';
rootZ = '\\zserver\Data\Subjects';

for j = 1:length(probeName)
    fname = sprintf('%s_%s_%s_g0_t0.imec.ap_CAR.bin', mname, datexp, probeName{j});
    ops.fbinary     = fullfile(rootZ, mname, datexp, sprintf('ephys_%s', probeName{j}), fname);    
    ops.fproc       = 'G:\DATA\Spikes\temp_wh.dat'; % residual from RAM of preprocessed data
    ops.dir_rez     = 'G:\DATA\Spikes\';
    
    % preprocess data
    rez = preprocessDataSub(ops);
   
    
    % cluster the threshold crossings
    rez = fwbwClustering(rez);
    
    % save the result file
    fname = fullfile(ops.dir_rez,  sprintf('rez_%s_%s_%s.mat', mname, datexp, probeName{j}));
    save(fname, 'rez', '-v7.3');
end