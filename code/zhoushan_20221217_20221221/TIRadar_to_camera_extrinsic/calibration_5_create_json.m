clear; close all; clc;

addpath('../../3rdpart/jsonlab');

output_folder = './';
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
    fprintf('create %s\n', output_folder);
end

save_as_json('./res_IRayCamera.mat', fullfile(output_folder, 'TIRadar_to_IRayCamera_extrinsic.json'));
save_as_json('./res_LeopardCamera0.mat', fullfile(output_folder, 'TIRadar_to_LeopardCamera0_extrinsic.json'));
save_as_json('./res_LeopardCamera1.mat', fullfile(output_folder, 'TIRadar_to_LeopardCamera1_extrinsic.json'));

function save_as_json(calibres_path, output_path)
    load(calibres_path);

    output = struct();

    output.R = Bx(1:3, 1:3);
    output.T = Bx(1:3, 4)';
    Bx(4,:) = [0,0,0,1];
    output.RT = Bx;
    
    savejson('', output, output_path);
    fprintf('finish outputing %s\n', output_path);
end