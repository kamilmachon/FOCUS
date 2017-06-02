function [mapa, t] = mapCombine(map1, map2, varargin)
% Combines two given maps by computing weighted average for each pixel,
% where weight is G channel. If one map is smaller than the other area
% outside of smaller map will be unchanged bigger map
% input arguments:
% map1, map2 - two RGB maps, (MxNx3 matrices), where R is height and G is
% weight
% time - name-value pair, logical value specyfing whether to measure
% computation time, 0 by default
% display - name-value pair, logical value specyfing wheter to display the
% result
% Outputs:
% mapa - result map of size MxNx3, where [M, N] are size of the bigger of two input
% maps
% t - computation time or 0 if time is set to false

p = inputParser;

defaultTime = false;
defaultDisp = false;
addParameter(p, 'time', defaultTime, @islogical);
addParameter(p, 'display', defaultDisp, @islogical);
parse(p,varargin{:});
time = p.Results.time;
display = p.Results.display;

classes = {'numeric'};
attributes = {'3d', 'size', [NaN, NaN, 3]};

validateattributes(map1, classes, attributes, mfilename, 'map1', 1);
validateattributes(map2, classes, attributes, mfilename, 'map2', 1);

if(time)
    tic
end
% Swapping maps if the second is bigger than the first
if size(map2, 1)>size(map1, 1)
    [map1, map2] = deal(map2, map1);
end

% Creating output map by copying bigger one

mapa = map1;
s11 = size(map1, 1);
s12 = size(map1, 2);
s21 = size(map2, 1);
s22 = size(map2, 2);

%Computing new weights ahead
if(size(map1) == size(map2))
    mapa = map1;
    w1 = map1(:, :, 2).^2;
    w2 = map2(:, :, 2).^2;
    w3 = w1+w2;
    w3 = sqrt(w3);
    mr1 = map1(:, :, 1);
    mg1 = map1(:, :, 2);
    mr2 = map2(:, :, 1);
    mg2 = map2(:, :, 2);
    mapa(:, :, 2) = w3;
    mr3 = (mr1.*mg1+mr2.*mg2)./(mg1+mg2);
%     mr3(isnan(mr3)) = 0;
    mapa(: , :, 1) = mr3;
else
    if size(map2, 1)>size(map1, 1)
        [map1, map2] = deal(map2, map1);
    end  
    mapa = map1;
    s11 = size(map1, 1);
    s12 = size(map1, 2);
    s21 = size(map2, 1);
    s22 = size(map2, 2);
    for i = 1:s11
        for j = 1:s12
            if i<s21 && j<s22
                mapa(i, j, 1) = (map1(i, j, 1)*map1(i, j, 2) + map2(i, j, 1)*map2(i, j, 2))/(map1(i, j, 2)+map2(i, j, 2));
                mapa(i, j, 2) = sqrt(w1(i, j) + w2(i, j));
            end
        end
    end
end
% Displaying map if specified so in input arguments

if(display)
    figure('Name', 'Combined map', 'NumberTitle', 'off')
    subplot(1, 4, 1)
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
if(time)
    t = toc;
else
    t = 0;
end