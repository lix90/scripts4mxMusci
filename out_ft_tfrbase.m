inputDir = '~/Desktop/huna/';
outputDir = '~/Desktop/huna/output/';
conditions = {'25', '45', '5', '6', '65'};
t = [0.2 0.4];
f = [4 7];
e = {'FC2'};
s = 1; % subject codings


%%
if min(f)>=30
    lowOrHigh = 'high';
else
    lowOrHigh = 'low';
end
    
if ~exist(outputDir, 'dir'); mkdir(outputDir); end
outputFilename = sprintf('%s_%s_%s_f%i-%i_t%i-%i.csv',...
                         lowOrHigh, condition, strcellcat(e, '-'),...
                         f(1), f(2), t(1)*1000, t(2)*1000);
outputFilenameFull = fullfile(outputDir, outputFilename);
fid = fopen(outputFilenameFull, 'w');
fprintf(fid, 'subj,%s\n', strcellcat(conditions, ','));

for i = s
    
    if i<10
        filename = sprintf('CW_grandTFRbase_%s_0%i.mat', lowOrHigh, i);
    else
        filename = sprintf('CW_grandTFRbase_%s_%i.mat', lowOrHigh, i);
    end

    load(fullfile(inputDir, filename));

    fprintf(fid, '%i,', i);

    for ii = 1:numel(conditions)
        
        var = eval(sprintf('grandTFRbase_%s', conditions{ii}));

        p = var.powspctrm;

        freq = var.freq;
        time = var.time;
        t1 = find(time>t(1), 1, 'first');
        t2 = find(time<t(2), 1, 'last');
        f1 = find(freq>f(1), 1, 'first');
        f2 = find(freq<f(2), 1, 'last');

        chanlabels = var.label;
        idxChan = ismember(chanlabels, e);

        sub_pow = squeeze(mean(mean(mean(p(idxChan, f1:f2, t1:t2), 1), 2), 3));

        if ii == numel(conditions)
            fprintf(fid, '%f\n', sub_pow);
        else
            fprintf(fid, '%f,', sub_pow);
        end

    end

end

fclose(fid);