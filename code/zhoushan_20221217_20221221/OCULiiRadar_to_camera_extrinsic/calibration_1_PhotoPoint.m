%% find corner reflector in pixel coordinate
clear all;  close all; clc;
addpath('./3rdpart');

% camera = 'IRayCamera';
% camera = 'LeopardCamera0';
camera = 'LeopardCamera1';

camera_instrinsic = load(fullfile('../camera_intrinsic', strcat(camera, '.mat')));
camera_instrinsic = camera_instrinsic.cameraParams;

image_folder= camera;

image_list = dir(image_folder);
image_list_name = sort_nat({image_list.name});
image_list_name = image_list_name(3:end);

points_pixel = zeros(length(image_list_name), 2);
figure(1);
for i=1:length(image_list_name)
    disp('=====================================================');
    image_path = fullfile(image_folder, image_list_name{i});
    
    image=imread(image_path);
    [image_undistort, new_origin] = undistortImage(image, camera_instrinsic);
    
%     subplot(1,2,1);
%     imshow(image);
%     title(image_path, 'Interpreter', 'none');

%     subplot(1,2,2);
    imshow(image_undistort);
    title(strcat(image_path, ' (undistort)'), 'Interpreter', 'none');
    set(gcf,'outerposition',get(0,'screensize'));%使该图显示最大化，便于取点
    
    prompt = '是否使用此帧? Y/N: ';
    str = input(prompt, 's');
    if strcmp(str, 'Y') || strcmp(str, 'y')
        disp('请选取目标点');
        [points_pixel(i,1), points_pixel(i,2)] = ginput(1);
        hold on;
        scatter(points_pixel(i,1), points_pixel(i,2), 'yellow', 'filled');
        hold off;
        pause(1);
    else
        continue;
    end

end

res_path = fullfile('./', strcat('res_', camera, '.mat'));
if ~exist(res_path, 'file')
    save(res_path, "points_pixel");
else
    res = load(res_path);
    res.points_pixel = points_pixel;
    
    cmd = 'save(res_path';
    fns = fieldnames(res);
    for i = 1:length(fns)
        cmd = strcat(cmd, sprintf(', "%s"', fns{i}));
    end
    cmd = strcat(cmd, ');');
    eval(cmd);
end

