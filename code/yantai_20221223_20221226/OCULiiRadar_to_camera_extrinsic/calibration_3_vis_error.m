%% ŒÛ≤Ó÷±∑ΩÕº
clear all;  close all; clc;

% camera = 'IRayCamera';
% camera = 'LeopardCamera0';
camera = 'LeopardCamera1';

res_path = fullfile('./', strcat('res_', camera, '.mat'));
load(res_path);

SAVE_ON = 1;
save_results_folder = strcat('vis_', camera);
if ~exist(save_results_folder, "dir") && SAVE_ON
    mkdir(save_results_folder);
end

error = [];
for i=1:length(points)    
    xyz = points(i, 1:3)';  
    xyz1=[xyz;ones(1,size(xyz,2))];
    uv1=Hx*xyz1*(diag(1./([0,0,1]*Hx*xyz1)));
    uv=uv1(1:2, :);
    uv = round(uv);
    error(i)=norm(uv - points(i,4:5)');    
end

bar(error);
hold on;
line([0, length(error)+0.5], [mean(error), mean(error)],'linewidth',2,'color', 'r');
text(length(error), mean(error), sprintf('%.3f', mean(error)));
hold off;
grid on;
xlabel('groupId');
ylabel('(u, v) L2 error');
ylim([0,200]);

saveas(gcf, fullfile(save_results_folder, 'error.png'));
