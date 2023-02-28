function helperFuseLidarCamera(imageFileNames, ptCloudFileNames, indices, intrinsic, tform)
%helperFuseLidarCamera To visualize lidar features.
%
% This is an example helper function that is subject to change or removal in
% future releases.

% Copyright 2019-2020 The MathWorks, Inc.

pc = pcread(ptCloudFileNames{1});

indices = indices(~cellfun('isempty',indices));
figureH = figure('Position', [0, 0, 640, 480]);
panel = uipanel('Parent',figureH,'Title','Colored Lidar Points', 'Position',[0.01,0,1,0.55]);
ax = axes('Parent',panel,'Color',[0,0,0],'Position',[0 0 1 1],'NextPlot','add');
axis(ax,'equal');
zoom on;
scatterH = scatter3(ax, nan, nan, nan, 20, '.');
view([-10, 40]);
campos([-117.6074  -48.5841   53.3789]);

imagepanel = uipanel('Parent',figureH,'Title','Projected Lidar Points', 'Position',[0.01,0.55,1,0.45]);
imax = axes('Parent',imagepanel,'Color',[0,0,0],'Position',[0 0 1 1],'NextPlot','add');

imH = imshow([],'Parent',imax);
%imax.NextPlot = 'add';
imax.Position = [0,0,1,1];
axis(imax, 'equal');
h = [];
numFrames = numel(ptCloudFileNames);
for i = 1:numFrames
    im = imread(imageFileNames{i});
    J = undistortImage(im, intrinsic);
    if ~isempty(h)
        delete(h);
    end
    imH.CData = J;
    
    ptCloud = pcread(ptCloudFileNames{i});
    xyzPts = ptCloud.Location;
    % check if the point cloud is organised
    if ~ismatrix(xyzPts)
        x = reshape(xyzPts(:, :, 1), [], 1);
        y = reshape(xyzPts(:, :, 2), [], 1);
        z = reshape(xyzPts(:, :, 3), [], 1);    
    else
        x = xyzPts(:, 1);
        y = xyzPts(:, 2);
        z = xyzPts(:, 3);
    end
    ptCloud = pointCloud([x, y, z]);
    plane = select(ptCloud, indices{i});
    [~, indice]= projectLidarPointsOnImage(ptCloud, intrinsic, tform);
    subpc = select(ptCloud, indice);
    ptCloud = fuseCameraToLidar(J, subpc, intrinsic, invert(tform));
    x = ptCloud.Location(:, 1);
    y = ptCloud.Location(:, 2);
    z = ptCloud.Location(:, 3);
   
    projectedPtCloud = projectLidarPointsOnImage(plane, intrinsic, tform);
    hold(imax,'on');
    h = plot(projectedPtCloud(:, 1), projectedPtCloud(:, 2), '.r');
    hold(imax,'off');
    set(scatterH,'XData',x,'YData',y,'ZData',z, 'CData', ptCloud.Color);
    pause(1);
%     key = waitforbuttonpress;
%     while(key==0)
%         key = waitforbuttonpress;
%     end
end
end