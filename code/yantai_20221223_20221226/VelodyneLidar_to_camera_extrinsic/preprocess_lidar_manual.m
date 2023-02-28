clearvars; close all; clc;

root = './VelodyneLidar_manual';
camera_timestamps_path = './camera_timestamps1.txt';
output_root = './VelodyneLidar_manual_pcd';

if ~exist(output_root, 'dir')
    mkdir(output_root);
    fprintf('create %s\n', output_root);
end

camera_timestamps = readlines(camera_timestamps_path);
camera_timestamps = camera_timestamps(1:end-1);
camera_timestamps = str2double(camera_timestamps);

items = dir(root);

data = struct();
cnt_data = 1;
for i = 1:length(items)
    if strcmp(items(i).name, '.') || strcmp(items(i).name, '..') || ~endsWith(items(i).name, '.csv')
        continue;
    end

    data(cnt_data).filename = items(i).name;
    data(cnt_data).filepath = fullfile(items(i).folder, items(i).name);
    data(cnt_data).timestamp = replace(items(i).name, '.csv', '');
    [~, data(cnt_data).id_pair] = min(abs(str2double(data(cnt_data).timestamp) - camera_timestamps));
    localtime = datetime(str2double(data(cnt_data).timestamp ), 'ConvertFrom', 'posixtime' ,'TimeZone', 'Asia/Calcutta');
    data(cnt_data).day = sprintf('%04d%02d%02d', localtime.Year, localtime.Month, localtime.Day);

    % csv to pcd
    % Point ID	Points_m_XYZ_0	Points_m_XYZ_1	Points_m_XYZ_2	azimuth	distance_m	intensity	laser_id	vertical_angle
    pcd = readmatrix(data(cnt_data).filepath);
    ptCloud = pointCloud(pcd(:, 2:4), "Intensity", pcd(:, 7));

    data(cnt_data).output_filename = sprintf('%s_%d.pcd', data(cnt_data).day, data(cnt_data).id_pair);
    data(cnt_data).output_filepath = fullfile(output_root, data(cnt_data).output_filename);
    pcwrite(ptCloud, data(cnt_data).output_filepath, "Encoding", "ascii");
    fprintf('(%d) generate %s\n', cnt_data, data(cnt_data).output_filename);

    cnt_data = cnt_data + 1;
end