function [groups] = clusterAnalysis(ptCloud, varargin)
% CLUSTERANALYSIS function
%   ptCloud - point cloud
%   Name-value pairs:
%       proximity - proximity in which points are considered part
%       of a cluster, default: 70
%       step - number of points compared during one loop, default: 10
%       minCluster - minimal number of points at which cluster is
%       preserved, default: 20
%       xlim - [x1, x2] - upper and lower limits of x axis (width),
%       default: [-1000, 2000]
%       ylim - [y1, y2] - upper and lower limits of y axis (height),
%       default: [-2000, 4000]
%       zlim - [z1, z2] - upper and lower limits of z axis (depth),
%       default: [-5000, -1000]
p = inputParser;

defaultxlim = [-1000, 2000];
defaultzlim = [-5000, -1000];
defaultylim = [-2000, 4000];
defaultProx = 70;
defaultStep = 10;
defaultMinCl = 20;
defaultDisp = 0;

validateattributes(ptCloud, {'pointCloud'}, {'scalar'}, mfilename, 'ptCloud', 1);

classes = {'numeric'};
attributes = {'size', [1, 2]};
validFcn = @(f) validateattributes(f, classes, attributes);

addParameter(p, 'xlim', defaultxlim, validFcn);
addParameter(p, 'ylim', defaultylim, validFcn);
addParameter(p, 'zlim', defaultzlim, validFcn);
addParameter(p, 'proximity', defaultProx, @isnumeric);
addParameter(p, 'step', defaultStep, @isnumeric);
addParameter(p, 'minCluster', defaultMinCl, @isnumeric);
addParameter(p, 'display', defaultDisp, @islogical);
parse(p, varargin{:});

dxThresh = p.Results.xlim(1);
xthresh = p.Results.xlim(2);
dyThresh = p.Results.ylim(1);
ythresh = p.Results.ylim(2);
dzThresh = p.Results.zlim(1);
zthresh = p.Results.zlim(2);
prox = p.Results.proximity;
step = p.Results.step;
mincl = p.Results.minCluster;
display = p.Results.display;

points3D = ptCloud.Location;
color = ptCloud.Color;

% First filter, limits the ptCloud to specified upper and lower bounds at
% every axis, thus removing a lot of thrash points generated around area of
% interest and makes ptCloud display properly

k = 0;
for i = 1:size(points3D, 1)
    if(points3D(i, 1) > xthresh || points3D(i, 1) < dxThresh ||...
            points3D(i, 2) > ythresh || points3D(i, 2) < dyThresh ||...
            points3D(i, 3) > zthresh || points3D(i, 3) < dzThresh)
        k = k + 1;
        del(k) = i;
    end
end

% Deleting excess points
points3D(del, :) = [];
color(del, :) = [];

% Creating ptCloud from remaining points
ptCloud = pointCloud(points3D, 'Color', color);

% Clusterization - iterative algorithm checking 'step' nearest points, and
% assigning any points closer than 'proximity' to the same cluster

clust = zeros(size(points3D, 1), 1);% array for checking points affiliation
% to a preexisting cluster
k = 1;                              % cluster number
n = 2;                              % point number
groups(1, 1) = 1;                   % array (k, n) containing clusters
% and their points
clust(1) = 1;                       % first point of array
% is starting point
cp = 1;                             % currently examined point (column
% index in groups matrix)

while nnz(clust) < size(clust, 1)
    pt = groups(k, cp);
    [indices, dists] = findNearestNeighbors(ptCloud,...
        [points3D(pt, 1) points3D(pt, 2) points3D(pt, 3)], step);
    for i = 1:step
        if(dists(i) < prox && clust(indices(i)) == 0)
            clust(indices(i)) = k;
            groups(k, n) = indices(i);
            n = n + 1;
        end
    end
    if (cp < n - 1)
        cp = cp + 1;
    else
        cp = 1;
        k = k + 1;
        n = 1;
        if(~isempty(find(clust == 0, 1, 'first')))
            groups(k, cp) = find(clust == 0, 1, 'first');
        end
    end
end

% Second filter, discarding clusters smaller that minCl points
if(size(groups, 2) > mincl)     % Checking if any cluster eligible
    % if not - skip filtering and display
    k = 1;
    i = 1;
    
    while i <= size(groups, 1)
        while(k < mincl)
            if(groups(i, k) == 0)
                index = true(1, size(groups, 1));
                index(i) = false;
                groups = groups(index, :);
                i = i - 1;
                break;
            end
            k = k + 1;
        end
        i = i + 1;
        k = 1;
    end
    
    if(display)
        f1 = figure('Name', 'Clustered points on top of whole cloud', 'NumberTitle', 'off');
        f2 = figure('Name', 'All Clusters', 'NumberTitle', 'off');
        % Display starting ptCloud
        figure(f1);
        hold on;
        pcshow(ptCloud, 'VerticalAxis', 'y', 'VerticalAxisDir', 'down',...
            'MarkerSize', 45);
        camorbit(0, -30);
        camzoom(1.5);
        
        % Display all clusters on single 3d plot, each with different
        % hue of red, each cluster also displayed on top of whole
        % cloud on it's own plot
        
        for j = 1:size(groups, 1)
            
            hold on;
            vec = groups(j, :);
            vec = nonzeros(vec);    %creating vector of indices
            pts = points3D(vec, :);
            clr = color(vec, :);
            clr2 = clr;
            
            clr(:, 1) = floor(255 / (7 + size(groups, 1))) * (j+7);
            clr(:, 2) = 0;
            clr(:, 3) = 0;
            clr2(:, 1) = 0;
            clr2(:, 2) = 255;
            clr2(:, 3) = 0;
            
            ptClust = pointCloud(pts, 'Color', clr);
            
            % All clusters on top of whole cloud to recognize which points have
            % been grouped and which have not
            figure(f1)
            hold on;
            pcshow(ptClust, 'VerticalAxis', 'y', 'VerticalAxisDir', 'down',...
                'MarkerSize', 45);
            
            % All clusters to display filtered ptCloud consisting only of
            % clustered areas
            figure(f2);
            hold on;
            pcshow(ptClust, 'VerticalAxis', 'y', 'VerticalAxisDir', 'down',...
                'MarkerSize', 45);
            
            % Single cluster displayed on top of ptCloud to analyze how and
            % where clusterization happens
            figure('Name', strcat('Cluster number', j), 'NumberTitle', 'off')
            hold on;
            ptClust = pointCloud(pts, 'Color', clr2);
            pcshow(ptCloud, 'VerticalAxis', 'y', 'VerticalAxisDir', 'down',...
                'MarkerSize', 45);
            pcshow(ptClust, 'VerticalAxis', 'y', 'VerticalAxisDir', 'down',...
                'MarkerSize', 45);
        end
    end
    
end

