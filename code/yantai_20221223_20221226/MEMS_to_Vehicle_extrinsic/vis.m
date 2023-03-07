clearvars; close all; clc;

file_path = './heading_imu_input.csv';
data = readlines(file_path);
data = data(1:end-1, :);
data = split(data, ',');

x = str2double(data(2:end, 2));
y = str2double(data(2:end, 3));
z = str2double(data(2:end, 4));
idx = (1:size(data)-1)';

figure(1);
scatter3(x,y,z,1,idx,'filled');
grid on;
colormap('jet');
xlabel('x');
ylabel('y');
zlabel('z');
colorbar();

% axis('equal');