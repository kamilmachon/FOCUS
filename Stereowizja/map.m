function[mapa, t] = map(ptCloud, varargin)
% ptCloud - point cloud
% Name-value pairs:
% box - size of single map pixel in real life (in centimeters)
% default 1
% xlim - [x1, x2] - upper and lower limits of x axis(width)
% default [-5000, 5000]
% zlim - [z1, z2] - upper and lower limits of z axis(depth)
% default [-5000, 5000]
% ylim - [y1, y2] - upper and lower limits of y axis(height)
% default [-2000, 4000]
% display - if set to true will display map after computing
% time - if set to true will measure time and return it as second output
% output: map of size (x2-x1, y2-y1)/10*box in RGB, where:
% R represents medium height in milimeters mapped to 0-255
% G represents weight (confidence) of measurement, being no. of measurements
% mapped to 0-255
% B - not implemented yet. Will represent in 0-1 if terrain is traversible
% or traversibility of terrain defined by smallest or median directional
% derivative of height
% time - computation time or 0 if time set to false

% Parsing inputs

p = inputParser;

defaultxlim = [-5000, 5000];
defaultzlim = [-5000, 5000];
defaultylim = [-2000, 4000];
defaultbox = 1;
defaultDisp = false;
defaultTime = false;

classes = {'numeric'};
attributes = {'size',[1, 2]};
validFcn = @(f) validateattributes(f, classes, attributes);

addParameter(p,'xlim',defaultxlim,validFcn);
addParameter(p,'ylim',defaultylim,validFcn);
addParameter(p,'zlim',defaultzlim,validFcn);
addParameter(p, 'box', defaultbox, @isnumeric);
addParameter(p, 'display', defaultDisp, @islogical);
addParameter(p, 'time', defaultTime, @islogical);
parse(p,varargin{:});

validateattributes(ptCloud, {'pointCloud'}, {'scalar'}, mfilename, 'pointCloud', 3);

dxthresh= p.Results.xlim(1);
xthresh= p.Results.xlim(2);
dythresh = p.Results.ylim(1);
ythresh = p.Results.ylim(2);
dzthresh = p.Results.zlim(1);
zthresh = p.Results.zlim(2);
box = p.Results.box;
time = p.Results.time;
display = p.Results.display;

% starting timer for function

if(time)
    tic
end

% Calculating sizes of each map dimension

sx = abs(xthresh-dxthresh);
sy = abs(ythresh-dythresh);
sz = abs(zthresh-dzthresh);

% Trimming map to specified axes limits
points3D = ptCloud.Location;
color = ptCloud.Color;
k = 0;
del = zeros(size(points3D, 1), 1);
for i = 1:size(points3D, 1)
    if(points3D(i, 3) > zthresh || points3D(i, 3) < dzthresh || points3D(i, 1) > xthresh ||...
            points3D(i, 1) < dxthresh || points3D(i, 2) > ythresh || points3D(i, 2) < dythresh)
        k = k+1;
        del(k) = i;
    end
end
if(any(del))
    del = nonzeros(del);
    ind = true(1, size(points3D, 1));
    ind(del) = false;
    points3D = points3D(ind, :);
%     color(del, :) = [];
end

% Calculating size of map for specified limits and resolution

mapa = zeros(abs(xthresh-dxthresh)/(10*box), abs(zthresh-dzthresh)/(10*box), 3);

% Setting B channel to 1 (for now, until we find usage for it)

mapa(:,:,3) = 1;

% For each point of cloud, add it to the map weighing accordingly
mx = sx/size(mapa, 1);
mz = sz/size(mapa, 2);
for i = 1:size(points3D, 1)
    x = points3D(i, 1);
    y = points3D(i, 2);
    z = points3D(i, 3);
    py = floor( (x - dxthresh)/mx)+1;
    px = floor( (z - dzthresh)/mz)+1;
    mapa(px, py, 1) = (((y - dythresh)/(sy)*255)/(mapa(px, py, 2)+1) + mapa(px, py, 1)*mapa(px, py, 2)/(mapa(px, py, 2)+1))/255;
    mapa(px, py, 2) = mapa(px, py, 2)+1/255;
end

% Permute map for it to align with ptCloud

% mapa = permute(mapa, [2 1 3]);

% Measure time or set it to 0 if timing is switched of

if(time)
    t = toc;
else
    t = 0;
end

% If displaying turned on, display map and each channel separately in both
% absolute values and scaled to span for entire (or only) 0-255 range in
% each color

if(display)
    figure('Name', 'Absolute map', 'NumberTitle', 'off')
    subplot(2, 2, 1)
    imshow(mapa);
    title('Map');
    subplot(2, 2, 2)
    imshow(mapa(:, :, 1));
    title('R channel');
    subplot(2, 2, 3)
    imshow(mapa(:, :, 2));
    title('G channel');
    subplot(2, 2, 4)
    imshow(mapa(:, :, 3));
    title('B channel');
    figure('Name', 'Scaled map', 'NumberTitle', 'off')
    subplot(2, 2, 1)
    imshow(mapa, []);
    title('Map');
    subplot(2, 2, 2)
    imshow(mapa(:, :, 1), []);
    title('R channel');
    subplot(2, 2, 3)
    imshow(mapa(:, :, 2), []);
    title('G channel');
    subplot(2, 2, 4)
    imshow(mapa(:, :, 3), []);
    title('B channel');
end
