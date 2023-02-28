function helperShowImageCorners(imageCorners3d, imageFileNames, intrinsic)
% helperShowImageCorners Function to display checkerboard corners
%
% This is an example helper function that is subject to change or removal in
% future releases.

% Copyright 2019 The MathWorks, Inc.

figureH = figure('Position', [0, 0, 480, 320]);
panel = uipanel('Parent', figureH, 'Position', [0 0 1 1], 'Title', 'Image Features');
ax = axes('Parent',panel);
numImages = numel(imageFileNames);

for i = 1:numImages
    im = imread(imageFileNames{i});
    
    % Undistort image
    J = undistortImage(im, intrinsic);
    imCorners3d = imageCorners3d(:, :, i);
    imCorners2d = projectLidarPointsOnImage(imCorners3d, intrinsic, rigid3d());
    edge = [imCorners2d(4, 1:2); imCorners2d(1, 1:2)];
    imshow(J, 'Parent', ax);
    hold on;
    %draw detected edges on images
    plot(imCorners2d(1:2, 1), imCorners2d(1:2, 2), '-', 'Color',...
        'r', 'LineWidth' ,4, 'Parent' ,ax);
    plot(imCorners2d(2:3, 1), imCorners2d(2:3, 2), '-', 'Color',...
        'g', 'LineWidth', 4, 'Parent', ax);
    plot(imCorners2d(3:4, 1), imCorners2d(3:4, 2), '-', 'Color',...
        'b', 'LineWidth', 4,'Parent', ax);
    plot(edge(:, 1), edge(:, 2), '-', 'Color',...
        'y', 'LineWidth', 4, 'Parent', ax);
    %draw corners in images
    plot(imCorners2d(1, 1), imCorners2d(1, 2), 'or', 'MarkerSize', 10, 'Parent', ax);
    plot(imCorners2d(2, 1), imCorners2d(2, 2), 'og', 'MarkerSize', 10, 'Parent', ax);
    plot(imCorners2d(3, 1), imCorners2d(3, 2), 'ob', 'MarkerSize', 10, 'Parent', ax);
    plot(imCorners2d(4, 1), imCorners2d(4, 2), 'oy', 'MarkerSize', 10, 'Parent', ax);
    hold off;

    tmp = split(imageFileNames{i}, filesep);
    image_name = tmp{end};
    title(image_name, 'Interpreter', 'none');

    pause(1);
    
%     key = waitforbuttonpress;
%     while(key==0)
%         key = waitforbuttonpress;
%     end
end