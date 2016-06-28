clear, clc, close all

%% parameters
baseDir = '';
eeglabPath = '';
fieldtripPath = '';
inputTag = 'ica';
outputTag = 'dipfit';
fieldtripPath = '';
rvDipoleEstimate = 1;
rvReject = 0.15;
inBrain = 1;
poolSize = 4;

%%--------
inputDir = fullfile(baseDir, inputTag);
outputDir = fullfile(baseDir, outputTag);
if ~exist(outputDir, 'dir'); mkdir(outputDir); end
[inputFilename, id] = getFileInfo(inputDir, fileExtension, prefixPosition);

addPathFieldtrip(fieldtripPath);

setMatlabPool(poolSize);

setEEGLAB(eeglabPath);

parfor i = 1:numel(id)

    outputFilename = sprintf('%s_%s.set', id{i}, outputTag);
    outputFilenameFull = fullfile(outputDir, outputFilename);
    if exist(outName, 'file')
        warning('files already exist');
        continue
    end

    % load dataset
    [EEG, ALLEEG, CURRENTSET] = importEEG(inputDir, inputFilename{i});

    % dipfit
    EEG.etc.dipfit.rvDipoleEstimate = 1;
    EEG.etc.dipfit.rvReject = 0.15;
    EEG.etc.dipfit.inBrain = 1;
    [EEG, badICs] = dipReject(EEG, 'Spherical', rvDipoleEstimate, rvReject, ...
                              inBrain);
    EEG.reject.gcompreject = badICs;
    EEG = eeg_checkset(EEG);
    
    % saveset
    EEG.setname = sprintf('%s_%s', id{i}, outputTag);
    EEG = pop_saveset(EEG, 'filename', outputFilenameFull); 
    EEG = []; ALLEEG = []; CURRENTSET = [];

end
