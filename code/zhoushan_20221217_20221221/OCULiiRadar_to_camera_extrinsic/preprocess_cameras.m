clear; close all; clc;

raw_data_root = 'F:\sensors_calibration_v2\rawdata';
output_root = './';

raw_data_folders = [
    fullfile(raw_data_root, '20221217_calibration\cameras_radars_calibration\cameras')
    ];

for k = 1:size(raw_data_folders, 1)
    disp('===========================================');
    raw_data_folder = raw_data_folders(k, :);

    % group pairs
    data = struct();
    cnt_data = 0;
    timestamps = {};
    
    filenames = dir(raw_data_folder);
    for i = 1:length(filenames)
        if strcmp(filenames(i).name, '.') || strcmp(filenames(i).name, '..')
            continue;
        end
    
        tmp = strsplit(filenames(i).name, '.');
        data(cnt_data+1).path = fullfile(filenames(i).folder, filenames(i).name);
        data(cnt_data+1).timestamp = strcat(tmp{1},'.',tmp{2});
        data(cnt_data+1).camera_id = tmp{3};
        data(cnt_data+1).type = tmp{4};
        
        if ~ismember(data(cnt_data+1).timestamp, timestamps)
            timestamps{length(timestamps)+1} = data(cnt_data+1).timestamp;
        end
        data(cnt_data+1).pair_id = find(strcmp(timestamps, data(cnt_data+1).timestamp));
        tmp = regexp(filenames(i).folder, '[0-9]{8}', 'match');
        data(cnt_data+1).day = tmp{1};
    
        cnt_data = cnt_data + 1;
    end
    
    % output
    if ~exist(output_root, 'dir')
        mkdir(output_root);
        fprintf('create %s\n', output_root);
    end
    
    for i = 1:length(data)
        source_path = data(i).path;
    
        destination_folder = fullfile(output_root, data(i).camera_id);
        if ~exist(destination_folder, 'dir')
            mkdir(destination_folder);
            fprintf('create %s\n', destination_folder);
        end
           
        destination_path = fullfile( ...
            destination_folder, ...
            strcat(data(i).day, '_', num2str(data(i).pair_id), '.', data(i).type) ...
            );
    
        state = copyfile(source_path, destination_path, 'f');
        fprintf('%d/%d finish copy %s\n', i, length(data), destination_path);
    end

    %% record timestamps
    fid = fopen(fullfile(output_root, sprintf('camera_timestamps%d.txt', k)), 'w');
    for i = 1:length(timestamps)
        fprintf(fid, '%s\n', timestamps{i});
    end
    fclose(fid);
end


