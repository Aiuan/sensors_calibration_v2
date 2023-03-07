clearvars;close all;clc;

output_folder = 'results';
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
    fprintf('create %s\n', output_folder);
end

calib_root = './';
calib_folders = dir(calib_root);

for i = 1:length(calib_folders)
    if calib_folders(i).isdir == 0
        continue;
    end

    if strcmp(calib_folders(i).name, '.') || strcmp(calib_folders(i).name, '..') || strcmp(calib_folders(i).name, output_folder)
        continue;
    end
    
    disp('=======================================');
    calib_subfolder = calib_folders(i).name;
    disp(calib_subfolder);
    calib_subfolder_path = fullfile(calib_folders(i).folder, calib_subfolder);
    items = dir(calib_subfolder_path);
    for j = 1:length(items)
        if items(j).isdir == 1
            continue
        end

        % .json
        if ~isempty(regexp(items(j).name, '_intrinsic.json$', 'match'))
            src = fullfile(items(j).folder, items(j).name);
            dst = fullfile(output_folder, items(j).name);
            copyfile(src, dst);
        end
        if ~isempty(regexp(items(j).name, '_extrinsic.json$', 'match'))
            src = fullfile(items(j).folder, items(j).name);
            dst = fullfile(output_folder, items(j).name);
            copyfile(src, dst);
        end
        
        % TIRadar calibration
        if ~isempty(regexp(items(j).name, '^mode[0-9]_[0-9]*x[0-9]*.mat$', 'match'))
            src = fullfile(items(j).folder, items(j).name);
            dst = fullfile(output_folder, items(j).name);
            copyfile(src, dst);
        end
    end

end