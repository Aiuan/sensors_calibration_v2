function helperShowCheckerboardPlanes(ptCloudFileNames, indices, imageFileNames, imageCorners3d, intrinsic)
numFrames = numel(ptCloudFileNames);
figure();
for i = 1:numFrames
    image_path = imageFileNames{i};
    image = imread(image_path);
    tmp = split(image_path, filesep);
    image_name = tmp{end};

    pcd_path = ptCloudFileNames{i};
    pcd = pcread(pcd_path);
    tmp = split(pcd_path, filesep);
    pcd_name = tmp{end};

    lidarCheckerboardPlane = select(pcd, indices{i});

    imCorners3d = imageCorners3d(:, :, i);
    imCorners2d = projectLidarPointsOnImage(imCorners3d, intrinsic, rigid3d());

    subplot(2,2,3);
    pcshowpair(pcd, lidarCheckerboardPlane, 'AxesVisibility', 'on');
    title(pcd_name, 'Interpreter', 'none');
    xlabel('x');
    ylabel('y');
    zlabel('z');
    xlim([-20, 20]);
    ylim([0, 40]);    
    view([0,90]);

    subplot(2,2,4);
    pcshowpair(pcd, lidarCheckerboardPlane, 'AxesVisibility', 'on');
    title(pcd_name, 'Interpreter', 'none');
    xlabel('x');
    ylabel('y');
    zlabel('z');

    subplot(2,2,[1, 2]);
    imshow(image);
    hold on;
    scatter(imCorners2d(1,1), imCorners2d(1,2), 'filled', 'r');
    plot(imCorners2d(1:2, 1), imCorners2d(1:2, 2), '-', 'Color', 'r', 'LineWidth' ,1);
    scatter(imCorners2d(2,1), imCorners2d(2,2), 'filled', 'g');
    plot(imCorners2d(2:3, 1), imCorners2d(2:3, 2), '-', 'Color', 'g', 'LineWidth' ,1);
    scatter(imCorners2d(3,1), imCorners2d(3,2), 'filled', 'b');
    plot(imCorners2d(3:4, 1), imCorners2d(3:4, 2), '-', 'Color', 'b', 'LineWidth' ,1);
    scatter(imCorners2d(4,1), imCorners2d(4,2), 'filled', 'y');
    plot(imCorners2d([4, 1], 1), imCorners2d([4, 1], 2), '-', 'Color', 'y', 'LineWidth' ,1);
    hold off;
    title(image_name, 'Color', 'w', 'Interpreter', 'none');

    pause(1);
%     key = waitforbuttonpress;
%     while(key==0)
%         key = waitforbuttonpress;
%     end
end
end