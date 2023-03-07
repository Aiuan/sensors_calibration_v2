clearvars; close all; clc;
addpath('../../3rdpart/jsonlab');

group_root = 'F:\dataset_v2\20221217_group0002_mode2_380frames';
LeopardCamera0_json_path = '../camera_intrinsic/LeopardCamera0_intrinsic.json';
OCULiiRadar2LeopardCamera0_json_path = '../OCULiiRadar_to_camera_extrinsic/OCULiiRadar_to_LeopardCamera0_extrinsic.json';
VelodyneLidar2LeopardCamera0_json_path = '../VelodyneLidar_to_camera_extrinsic/VelodyneLidar_to_LeopardCamera0_extrinsic.json';
output_root = './runs';

if ~exist(output_root, "dir")
    mkdir(output_root);
    fprintf('create %s\n', output_root);
end

LeopardCamera0_json = loadjson(LeopardCamera0_json_path);
LeopardCamera0_intrinsic = cameraParameters( ...
    "K", LeopardCamera0_json.intrinsic_matrix, ...
    "RadialDistortion", LeopardCamera0_json.radial_distortion, ...
    "TangentialDistortion", LeopardCamera0_json.tangential_distortion ...
    );
OCULiiRadar2LeopardCamera0_json = loadjson(OCULiiRadar2LeopardCamera0_json_path);
OCULiiRadar2LeopardCamera0_extrinsic = OCULiiRadar2LeopardCamera0_json(1).RT;

VelodyneLidar2LeopardCamera0_json = loadjson(VelodyneLidar2LeopardCamera0_json_path);
VelodyneLidar2LeopardCamera0_extrinsic = VelodyneLidar2LeopardCamera0_json(1).RT;

OCULiiRadar2VelodyneLidar_init = inv(VelodyneLidar2LeopardCamera0_extrinsic) * OCULiiRadar2LeopardCamera0_extrinsic;

[pitch, roll, yaw, tx, ty, tz] = pose_decode(OCULiiRadar2VelodyneLidar_init);
r2l = pose_encode(pitch, roll, yaw, tx, ty, tz);

frames_info = dir(group_root);
frames_info = frames_info(3:end, :);
zone = [-100, 100; 0, 100; -inf, inf];

tmp = split(group_root, filesep);
vedio_path = fullfile(output_root, strcat(tmp{end}, '.mp4'));
fps = 10;
if exist(vedio_path, 'file')
    delete(vedio_path);
    fprintf('delete %s\n', vedio_path);
end
aviobj = VideoWriter(vedio_path, 'MPEG-4');
aviobj.FrameRate=fps;
open(aviobj);

fig = figure("Position", [0, 0, 1280, 720], "Color", "white", "Visible", "off");
for i = 1:size(frames_info, 1)
    frame_foldername = frames_info(i).name;
    frame_idx = str2double(replace(frame_foldername, 'frame', ''));
    frame_folderpath = fullfile(frames_info(i).folder, frame_foldername);
    
    [img_ts, img] =find_image(fullfile(frame_folderpath, 'LeopardCamera0'));
    img_undistort = undistortImage(img, LeopardCamera0_intrinsic);
    [pcd1_ts, xyz1, other1] = find_pcd(fullfile(frame_folderpath, 'OCULiiRadar'));
    [pcd2_ts, xyz2, other2] = find_pcd(fullfile(frame_folderpath, 'VelodyneLidar'));
    
    xyz1_tf = tf(xyz1, r2l);

    [xyz1_tf_inzone, other1_inzone] = inzone(xyz1_tf, other1, zone);
    [xyz2_inzone, other2_inzone] = inzone(xyz2, other2, zone);    
    
    scatter3(xyz2_inzone(:, 1), xyz2_inzone(:, 2), xyz2_inzone(:, 3), 1, 'white', 'filled');
    hold on;
    scatter3(xyz1_tf_inzone(:, 1), xyz1_tf_inzone(:, 2), xyz1_tf_inzone(:, 3), 4, other1_inzone(:, 1), 'filled');
    hold off;
    xlabel('x');
    ylabel('y');
    zlabel('z');
    axis('equal');
    view([0, 90]);
    xlim([zone(1, 1), zone(1, 2)]);
    ylim([zone(2, 1), zone(2, 2)]);
    zlim([zone(3, 1), zone(3, 2)]);
    grid on;
    colormap('jet');
    colorbar;
    set(gca, 'CLim', [-5, 5]);
    ylabel(colorbar,'doppler(m/s)');
    set(gca, 'Color', 'black');
    set(gca, 'GridColor', [0.9, 0.9, 0.9]);

    ts_diff = str2double(pcd1_ts) - str2double(pcd2_ts);
    if ts_diff >= 0
        title_text = sprintf('OCULiiRadar: %s\nVelodyneLidar: %s\nOCULiiRadar-VelodyneLidar: +%.0f ms', pcd1_ts, pcd2_ts, abs(ts_diff)*1e3);
    else
        title_text = sprintf('OCULiiRadar: %s\nVelodyneLidar: %s\nOCULiiRadar-VelodyneLidar: -%.0f ms', pcd1_ts, pcd2_ts, abs(ts_diff)*1e3);
    end    
    title(title_text, 'Interpreter','none');


%     OCULiiRadar2LeopardCamera0_project = LeopardCamera0_json.intrinsic_matrix * OCULiiRadar2LeopardCamera0_extrinsic(1:3, :);
%     [uv_img, other_img] = projection(xyz1, other1, OCULiiRadar2LeopardCamera0_project, size(img));
%     
%     imshow(img);
%     hold on;
%     scatter(uv_img(:, 1), uv_img(:, 2), 4, other_img(:, 1), "filled");
%     hold off;
%     colormap('jet');
%     colorbar;
%     ts_diff = str2double(pcd1_ts) - str2double(img_ts);
%     if ts_diff >= 0
%         title_text = sprintf('OCULiiRadar: %s\nLeopardCamera0: %s\nOCULiiRadar-LeopardCamera0: +%.0f ms', pcd1_ts, img_ts, abs(ts_diff)*1e3);
%     else
%         title_text = sprintf('OCULiiRadar: %s\nLeopardCamera0: %s\nOCULiiRadar-LeopardCamera0: -%.0f ms', pcd1_ts, img_ts, abs(ts_diff)*1e3);
%     end    
%     title(title_text, 'Interpreter','none');
    
    image = getframe(fig).cdata;

    writeVideo(aviobj, image);
    fprintf('(%d/%d) %s is ok\n', i, size(frames_info, 1), frame_foldername);
end
close(aviobj);
fprintf('complete generating %s\n', vedio_path);

function [uv_img, other_img] = projection(xyz, other, project_matrix, img_size)
    xyz1 = xyz';
    xyz1(4, :) = 1;
    uvz = project_matrix * xyz1;
    uv1 = uvz ./ uvz(3, :);
    uv = uv1(1:2, :)';
    uv = round(uv);
    mask = (uv(:, 1)>=0 & uv(:, 1)<=img_size(2)) & (uv(:, 2)>=0 & uv(:, 2)<=img_size(1));
    uv_img = uv(mask, :);
    other_img = other(mask, :);
end

function [image_ts, image] =find_image(sensor_folder)
    image_info = dir(fullfile(sensor_folder, '*.png'));
    image_ts = replace(image_info(1).name, '.png', '');
    image_path = fullfile(image_info(1).folder, image_info(1).name);
    image = imread(image_path);
end

function [pitch, roll, yaw, tx, ty, tz] = pose_decode(extrinsic_matrix)
    pitch = asind(-extrinsic_matrix(3, 2));
    roll = asind(extrinsic_matrix(3, 1)/cosd(pitch));
    yaw = asind(extrinsic_matrix(1, 2)/cosd(pitch));
    tx = extrinsic_matrix(1, 4);
    ty = extrinsic_matrix(2, 4);
    tz = extrinsic_matrix(3, 4);

end

function [xyz_inzone, other_inzone] = inzone(xyz, other, zone)
    mask_x = xyz(:, 1) >= zone(1, 1) & xyz(:, 1) <= zone(1, 2);
    mask_y = xyz(:, 2) >= zone(2, 1) & xyz(:, 2) <= zone(2, 2);
    mask_z = xyz(:, 3) >= zone(3, 1) & xyz(:, 3) <= zone(3, 2);
    mask = mask_x & mask_y & mask_z;
    xyz_inzone = xyz(mask, :);
    other_inzone = other(mask, :);
end

function xyz_tf = tf(xyz, tf_matrix)
    xyz1 = xyz';
    xyz1(4, :) = 1;
    xyz1_tf = tf_matrix * xyz1;
    xyz_tf = xyz1_tf(1:3, :)';
end

function [pcd_ts, xyz, other] = find_pcd(sensor_folder)
    pcd_info = dir(fullfile(sensor_folder, '*.pcd'));
    pcd_ts = replace(pcd_info(1).name, '.pcd', '');
    pcd_path = fullfile(pcd_info(1).folder, pcd_info(1).name);
    pcd = readmatrix(pcd_path, 'FileType', 'text');
    xyz = pcd(:, 1:3);
    other = pcd(:, 4:end);
end

function extrinsic_matrix = pose_encode(pitch, roll, yaw, tx, ty, tz)
    extrinsic_matrix = zeros(4, 4);
    Rz = [
        cosd(yaw), sind(yaw), 0;
        -sind(yaw), cosd(yaw), 0;
        0, 0, 1
        ];
    Rx = [
        1, 0, 0;
        0, cosd(pitch), sind(pitch);
        0, -sind(pitch), cosd(pitch)
        ];
    Ry = [
        cosd(roll), 0, -sind(roll);
        0, 1, 0;
        sind(roll), 0, cosd(roll)
        ];
    extrinsic_matrix(1:3, 1:3) = Rz * Rx * Ry;
    extrinsic_matrix(1, 4) = tx;
    extrinsic_matrix(2, 4) = ty;
    extrinsic_matrix(3, 4) = tz;
    extrinsic_matrix(4, 4) = 1;

end