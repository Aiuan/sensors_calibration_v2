clear; close all; clc;

addpath('../../3rdpart/jsonlab');

output_folder = './';
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
    fprintf('create %s\n', output_folder);
end

save_as_json('LeopardCamera0.mat', fullfile(output_folder, 'LeopardCamera0_intrinsic.json'));
save_as_json('LeopardCamera1.mat', fullfile(output_folder, 'LeopardCamera1_intrinsic.json'));
save_as_json('IRayCamera.mat', fullfile(output_folder, 'IRayCamera_intrinsic.json'));

function save_as_json(calibres_path, output_path)
    load(calibres_path);

    output = struct();
    output.image_size = cameraParams.ImageSize;
    output.intrinsic_matrix = cameraParams.K;
    output.radial_distortion = cameraParams.RadialDistortion;
    output.tangential_distortion = cameraParams.TangentialDistortion;
    
    savejson('', output, output_path);
    fprintf('finish outputing %s\n', output_path);
end