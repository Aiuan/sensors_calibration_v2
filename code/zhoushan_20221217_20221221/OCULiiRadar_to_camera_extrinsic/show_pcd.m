clearvars; close all; clc;

folder_pcd = './OCULiiRadar';
folder_image = './LeopardCamera0';

pcds = dir(folder_pcd);
pcds = sort_nat({pcds.name});
pcds = pcds(3:end);

for i = 1:length(pcds)
    pcd_path = fullfile(folder_pcd, pcds{i});   
    % x,y,z,doppler,snr
    pcd_data = readmatrix(pcd_path, 'FileType', 'text');
    figure(1);
    scatter3(pcd_data(:, 1), pcd_data(:, 2), pcd_data(:, 3), 10, pcd_data(:, 5), "filled");
    xlabel('x/m');
    ylabel('y/m');
    zlabel('z/m');
    view([0, 0]);
    colormap('jet');
    grid on;
    xlim([-10, 10]);
    zlim([0, 20]);
    colorbar;
    
    pcd_data_interest = pcd_data;
    pcd_data_interest = pcd_data_interest(pcd_data_interest(:,1)>=-10, :);
    pcd_data_interest = pcd_data_interest(pcd_data_interest(:,1)<=10, :);
    pcd_data_interest = pcd_data_interest(pcd_data_interest(:,3)>=0, :);
    pcd_data_interest = pcd_data_interest(pcd_data_interest(:,3)<=20, :);
    pcd_data_interest = sortrows(pcd_data_interest,5);
    fprintf('%10s%10s%10s%10s%10s\n', 'x', 'y', 'z', 'doppler', 'snr');
    for j = 1 : length(pcd_data_interest)
        fprintf('%10.3f%10.3f%10.3f%10.3f%10.3f\n', pcd_data_interest(j, 1), pcd_data_interest(j, 2), pcd_data_interest(j, 3), pcd_data_interest(j, 4), pcd_data_interest(j, 5));
    end

    image_path = fullfile(folder_image, replace(pcds{i}, '.pcd', '.png'));
    image_data = imread(image_path);
    figure(2);
    imshow(image_data);
    title(replace(pcds{i}, '.pcd', '.png'));

%     %按键下一帧         
%     key = waitforbuttonpress;
%     while(key==0)
%         key = waitforbuttonpress;
%     end     

end
