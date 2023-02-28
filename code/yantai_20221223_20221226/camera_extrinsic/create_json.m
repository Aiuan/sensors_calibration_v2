clear; close all; clc;

addpath('../../3rdpart/jsonlab');

output_folder = './';
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
    fprintf('create %s\n', output_folder);
end

save_as_json('LeopardCamera0_to_LeopardCamera1.mat', fullfile(output_folder, 'LeopardCamera1_to_LeopardCamera0_extrinsic.json'));

function save_as_json(calibres_path, output_path)
    load(calibres_path);
    % LeopardCamera0_to_LeopardCamera1
    
    RT = stereoParams.PoseCamera2.A;
    RT(1:3, 4) = RT(1:3, 4) / 1e3;
    RT = inv(RT); % LeopardCamera1_to_LeopardCamera0

    output = struct();
    output.R = RT(1:3, 1:3);
    output.T = RT(1:3, 4)';
    output.RT = RT;
    
    savejson('', output, output_path);
    fprintf('finish outputing %s\n', output_path);
end