function [exmap, t] = expol(mapa, varargin)
% Extrapolates missing points in already mapped area of the map
% Inputs:
% mapa - RGB map to be filled
% name-value pairs:
% display - if set to true will display map after computing
% mesh - if set to true will display mesh after computing
% time - if set to true will measure time and return it as second output
p = inputParser;

defaultTime = false;
defaultDisp = false;
defaultMesh = false;
addParameter(p, 'time', defaultTime, @islogical);
addParameter(p, 'display', defaultDisp, @islogical);
addParameter(p, 'mesh', defaultMesh, @islogical);
parse(p,varargin{:});
time = p.Results.time;
display = p.Results.display;
msh = p.Results.mesh;

classes = {'numeric'};
attributes = {'3d', 'size', [NaN, NaN, 3]};
validateattributes(mapa, classes, attributes, mfilename, 'mapa', 1);

if(time)
    tic
end
[temp, xmax] = find(mapa(:, :, 2), 1, 'last');
[temp, xmin] = find(mapa(:, :, 2), 1, 'first');
[temp, ymax] = find(transpose(mapa(:, :, 1)), 2, 'last');
[temp, ymin] = find(transpose(mapa(:, :, 1)), 2, 'first');

x = zeros(10000, 1);
y = zeros(10000, 1);
v = zeros(10000, 1);
k = 0;
for i = 1:size(mapa, 1)
    for j = 1:size(mapa, 2)
        if(mapa(i, j, 2)>0)
            k = k+1;
            x(k) = i;
            y(k) = j;
            v(k) = mapa(i, j, 1);
        end
    end
end
x = nonzeros(x);
y = nonzeros(y);
v = nonzeros(v);
exmap = mapa;
exmap(:, :, 1) = griddata(y, x, v, 1:size(mapa, 1), transpose(1:size(mapa,2)), 'natural');
if(display)
    figure('Name', 'Filled map', 'NumberTitle', 'off')
    subplot(2, 2, 1)
    imshow(exmap);
    title('Map');
    subplot(2, 2, 2)
    imshow(exmap(:, :, 1));
    title('R channel');
    subplot(2, 2, 3)
    imshow(exmap(:, :, 2));
    title('G channel');
    subplot(2, 2, 4)
    imshow(exmap(:, :, 3));
    title('B channel');
end
if(msh)
    figure('Name', 'Interpolated mesh', 'NumberTitle', 'Off')
    mesh(exmap(:, :, 1));
end
if(time)
    t = toc;
else
    t = 0;
end