function [] = showCloud(ptCloud, varargin)
% Displays ptCloud with previously specified parameters, possibly triming
% it to specific thresholds on each axis
% Inputs:
% ptCloud - point cloud to be displayed
% Name-value pairs:
% trim - logical value, if true the ptCloud will be trimmed to specific
% limits before displaying, false by default
% xlim, ylim, zlim - 2-element vectors specyfing lower and upper bound to
% which the cloud will be trimmed on each axis
% xtrim, ytrim, ztrim - if trim is true, these specify whether to trim
% cloud along specified axis, all true by default
% (You can disable trimming along specified axis by setting each of those
% to false)
% fig - if false function doesn't create new figure for displaying ptCloud
defaultx = [-1000, 2000];
defaulty = [-2000, 4000];
defaultz = [-4000, 0];
defaultTrim = false;
defaultZTrim = true;
defaultYTrim = true;
defaultXTrim = true;
defaultFig = true;

validateattributes(ptCloud, {'pointCloud'}, {'scalar'}, mfilename, 'pointCloud', 1);

classes = {'numeric'};
attributes = {'size',[1, 2]};
validFcn = @(f) validateattributes(f, classes, attributes);

p = inputParser;

addParamValue(p, 'xlim', defaultx, validFcn);
addParamValue(p, 'ylim', defaulty, validFcn);
addParamValue(p, 'zlim', defaultz, validFcn);
addParamValue(p, 'trim', defaultTrim, @islogical);
addParamValue(p, 'xtrim', defaultXTrim, @islogical);
addParamValue(p, 'ytrim', defaultYTrim, @islogical);
addParamValue(p, 'ztrim', defaultZTrim, @islogical);
addParamValue(p, 'fig', defaultFig, @islogical);

parse(p, varargin{:});

dxthresh= p.Results.xlim(1);
xthresh= p.Results.xlim(2);
dythresh = p.Results.ylim(1);
ythresh = p.Results.ylim(2);
dzthresh = p.Results.zlim(1);
zthresh = p.Results.zlim(2);
trim = p.Results.trim;
xtrim = p.Results.xtrim;
ytrim = p.Results.ytrim;
ztrim = p.Results.ztrim;
fig = p.Results.fig;

if(trim)
    points3D = ptCloud.Location;
    color = ptCloud.Color;
    k = 0;
    del(1) = 0;
    for i = 1:size(points3D, 1)
        if((xtrim && (points3D(i, 1) > xthresh || points3D(i, 1) < dxthresh)) ...
                ||(ytrim && (points3D(i, 2) > ythresh || points3D(i, 2) < dythresh)) ...
                ||(ztrim && (points3D(i, 3) > zthresh || points3D(i, 3) < dzthresh)))
            k = k+1;
            del(k) = i;
        end
    end
    if(any(del))
        points3D(del, :) = [];
        color(del, :) = [];
    end
    ptCloud = pointCloud(points3D, 'Color', color);
end
if(fig)
    figure('Name', 'Point cloud', 'NumberTitle', 'off')
end
% Visualising the point cloud
pcshow(ptCloud, 'VerticalAxis','y','VerticalAxisDir','down',...
    'MarkerSize',45);

% Labelling the axes
xlabel('x-axis');
ylabel('y-axis');
zlabel('z-axis');