clearvars; close all; clc;

folder_pcd = './TIRadar';
folder_image = './LeopardCamera0';

pcds = dir(folder_pcd);
pcds = sort_nat({pcds.name});
pcds = pcds(3:end);

for i = 1:length(pcds)
    pcd_path = fullfile(folder_pcd, pcds{i});   
    % x y z velocity range intensity noise snr
    pcd_data = readlines(pcd_path);
    pcd_data = pcd_data(11:end-1);
    pcd_data = split(pcd_data, ' ');
    pcd_data = str2double(pcd_data);
    figure(1);
    scatter3(pcd_data(:, 1), pcd_data(:, 2), pcd_data(:, 3), 10, pcd_data(:, 8), "filled");
    xlabel('x/m');
    ylabel('y/m');
    zlabel('z/m');
    view([-10, 80]);
    colormap('jet');
    grid on;
    xlim([-10, 10]);
    ylim([0, 20]);
    colorbar;
    
    pcd_data_interest = pcd_data;
    pcd_data_interest = pcd_data_interest(pcd_data_interest(:,1)>=-10, :);
    pcd_data_interest = pcd_data_interest(pcd_data_interest(:,1)<=10, :);
    pcd_data_interest = pcd_data_interest(pcd_data_interest(:,2)>=0, :);
    pcd_data_interest = pcd_data_interest(pcd_data_interest(:,2)<=20, :);
    pcd_data_interest = sortrows(pcd_data_interest, 6);
    fprintf('%10s%10s%10s%10s%10s%10s%10s%10s\n', 'x', 'y', 'z', 'velocity', 'range', 'intensity', 'noise', 'snr');
    for j = 1 : size(pcd_data_interest, 1)
        fprintf('%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f\n', ...
            pcd_data_interest(j, 1), pcd_data_interest(j, 2), pcd_data_interest(j, 3), ...
            pcd_data_interest(j, 4), pcd_data_interest(j, 5), pcd_data_interest(j, 6), ...
            pcd_data_interest(j, 7), pcd_data_interest(j, 8));
    end

    image_path = fullfile(folder_image, replace(pcds{i}, '.pcd', '.png'));
    if exist(image_path, 'file')
        image_data = imread(image_path);
        figure(2);
        imshow(image_data);
        title(replace(pcds{i}, '.pcd', '.png'), 'Interpreter','none');
    end    

    %按键下一帧         
%     key = waitforbuttonpress;
%     while(key==0)
%         key = waitforbuttonpress;
%     end     

end
