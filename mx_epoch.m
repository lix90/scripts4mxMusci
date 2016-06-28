%% eeglab pipeline for lqs: merge datasets
clear, clc, close

baseDir = '';
inputTag = 'dipfit';
outputTag = 'epoch';
fileExtension = 'set';
prefixPosition = 1;
poolSize = 2;
marks = {'S 53', 'S 58', 'S103', 'S108'};
timeRange = [-1, 2];
baseline = [-1000, 0];

%%============================================

inputDir = fullfile(baseDir, inputTag);
outputDir = fullfile(baseDir, outputTag);
if ~exist(outputDir, 'dir'); mkdir(outputDir); end
[inputFilename, id] = getFileInfo(inputDir, fileExtension, prefixPosition);

if exist('poolSize', 'var') && ~isempty(poolSize)
    setMatlabPool(poolSize)
end

setEEGLAB;

parfor i = 1:numel(id)

    outputFilename = sprintf('%s_%s.set', id{i}, outputTag);
    outputFilenameFull = fullfile(outputDir, outputFilename);
    if exist(outName, 'file'); warning('files already exist'); continue; end

    [EEG, ALLEEG, CURRENTSET] = importEEG(inputDir, inputFilename{i});
    
    % reject bad ICs
    EEG = pop_subcomp(EEG, [], 0);
    EEG = eeg_checkset(EEG);

    % low-pass filtering
    if exist('lowPassHz', 'var') && ~isempty(lowPassHz)
        EEG = pop_eegfiltnew(EEG, 0, lowPassHz);
        EEG = eeg_checkset(EEG);
    end
    
    % % interpolate channels
    % EEG = eeg_interp(EEG, chanlocs, 'spherical');
    % EEG = eeg_checkset(EEG);
    
    % epoch
    EEG = pop_epoch(EEG, marks, timeRange, 'epochinfo', 'yes');
    EEG = eeg_checkset(EEG);
    
    % baseline correction
    if exist('baseline', 'var') && ~isempty(baseline)
       EEG = pop_rmbase(EEG, baseline); 
       EEG = eeg_checkset(EEG);
    end
    
    EEG.setname = sprintf('%s_%s', id{i}, outputTag);
    EEG = pop_saveset(EEG, 'filename', outputFilenameFull);
    ALLEEG = []; EEG = []; CURRENTSET = [];
    
end