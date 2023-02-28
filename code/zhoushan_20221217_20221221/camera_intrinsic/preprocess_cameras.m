clear; close all; clc;

raw_data_root = 'F:\sensors_calibration_v2\rawdata';
output_root = './';

raw_data_folders = [
    fullfile(raw_data_root, '20221217_calibration\cameras_lidar_calibration\cameras'),
    fullfile(raw_data_root, '20221221_calibration\cameras_lidar_calibration\cameras')
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
end

%% IRayCamera official
clear; close all; clc;
data_official_path = 'F:\sensors_calibration_v2\rawdata\IRayCamera_official\data';
output_root = './';

if ~exist(output_root, 'dir')
    mkdir(output_root);
    fprintf('create %s\n', output_root);
end

filenames = dir(data_official_path);

for i = 3:length(filenames)
    source_path = fullfile(filenames(i).folder, filenames(i).name);

    destination_folder = fullfile(output_root, 'IRayCamera_official');
    if ~exist(destination_folder, 'dir')
        mkdir(destination_folder);
        fprintf('create %s\n', destination_folder);
    end
    
    tmp = regexp(filenames(i).name, '[0-9]{8}', 'match');
    day = tmp{1};
    tmp = split(filenames(i).name, '.');
    type = tmp{end};
    destination_path = fullfile( ...
            destination_folder, ...
            strcat(day, '_', num2str(i-2), '.', type) ...
            );

    state = copyfile(source_path, destination_path, 'f');
    fprintf('%d/%d finish copy %s\n', i-2, length(filenames)-2, destination_path);
    
end