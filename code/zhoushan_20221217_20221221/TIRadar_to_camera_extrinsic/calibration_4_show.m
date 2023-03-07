%% 可视化检查
clear all;  close all; clc;

camera = 'IRayCamera';
% camera = 'LeopardCamera0';
% camera = 'LeopardCamera1';

camera_instrinsic = load(fullfile('../camera_intrinsic', strcat(camera, '.mat')));
camera_instrinsic = camera_instrinsic.cameraParams;

res_path = fullfile('./', strcat('res_', camera, '.mat'));
load(res_path);

image_folder = camera;

SAVE_ON = 1;
WAITKEY_ON = 1-SAVE_ON;
save_results_folder = strcat('vis_', camera);
if ~exist(save_results_folder, "dir") && SAVE_ON
    mkdir(save_results_folder);
end

image_list = dir(image_folder);
image_list_name = sort_nat({image_list.name});
image_list_name = image_list_name(3:end)';

mask_use = (sum(points_xyz, 2) ~= 0) & (sum(points_pixel, 2) ~= 0);
image_list_name = image_list_name(mask_use);

figure();
for i=1:length(image_list_name)
    xyz=points(i,1:3)';
    xyz1=[xyz;1];
    uv1=Hx*xyz1*(diag(1./([0,0,1]*Hx*xyz1)));
    uv=uv1(1:2, :);
    uv=round(uv);
    error(i)=norm(uv - points(i,4:5)');

    image = imread(fullfile(image_folder, image_list_name{i}));
    [image_undistort, new_origin] = undistortImage(image, camera_instrinsic);

    imshow(image_undistort);
    hold on;
    scatter(points(i,4), points(i,5), 'filled', 'g');
    scatter(uv(1), uv(2), 'filled', 'r');    
    hold off;
    title( ...
        [image_list_name{i}, '    Error = ',num2str(error(i)), '    GT = (', num2str(points(i,4)), ',', num2str(points(i,4)), ')    Transfer = (', num2str(uv(1)), ',', num2str(uv(2)), ')'], ...
        'Interpreter','none' ...
        ); 
    
    if SAVE_ON
        saveas(gcf, [save_results_folder, '/match_', image_list_name{i}]);
    end 

    if WAITKEY_ON == 1
        %按键下一帧         
        key = waitforbuttonpress;
        while(key==0)
            key = waitforbuttonpress;
        end
    end   
end
