function [ptCloud, varargout] = make3D(frameLeft, frameRight, stereoParams, varargin)
% Function takes two pictures along with calculated stereo parameters and
% computes point cloud from them based on depth of each pixel
% Input arguments:
% frameLeft - left image as MxNx3 array in RGB
% frameRight - right image as MxNx3 array in RGB
% stereoParams - camera parameters calculated druing camera calibration
% optional input arguments:
% Name-value pairs:
% display - logical value, if true displays ptCloud after computation
% WARNING: display is very time consuming - use only for testing
% time - logical value, if true returns computation time in seconds as second output
% Output:
% ptCloud - computed point cloud
% time - calculation time in seconds, returned only if time input was
% specified as true
% fig - if displaying, setting this to false prevents from creating new
% figure for display

p = inputParser;

defaultDisp = false;
defaultTime = false;
defaultFig = true;

classes = {'numeric'};
attributes = {'3d', 'size', [NaN, NaN, 3]};
validateattributes(frameLeft, classes, attributes, mfilename, 'frameLeft', 1);
validateattributes(frameRight, classes, attributes, mfilename, 'frameRight', 2);
validateattributes(stereoParams, {'stereoParameters'}, {'scalar'}, mfilename, 'stereoParams', 3);

addParamValue(p, 'display', defaultDisp, @islogical);
addParamValue(p, 'time', defaultTime, @islogical);
addParamValue(p, 'fig', defaultFig, @islogical);

parse(p, varargin{:});

display = p.Results.display;
time = p.Results.time;
fig = p.Results.fig;
if(time)
    tic
end
% Rectify the frames.
[frameLeftRect, frameRightRect] = ...
    rectifyStereoImages(frameLeft, frameRight, stereoParams);

% Convert to grayscale.
frameLeftGray  = rgb2gray(frameLeftRect);
frameRightGray = rgb2gray(frameRightRect);

% Compute disparity.
disparityMap = disparity(frameLeftGray, frameRightGray);

% Reconstruct 3-D scene.
points3D = reconstructScene(disparityMap, stereoParams);

ptCloud = pointCloud(points3D, 'Color', frameLeftRect);

% Filter ptCloud of Nan and Inf points
ptCloud = removeInvalidPoints(ptCloud);

% If display option on, display ptCloud
if(display)
    showCloud(ptCloud, 'trim', true, 'fig', fig);
end

% If timing option on, return processing time as additional output
if(time)
    time = toc;
    varargout{1} = time;
else
    varargout{1} = 0;
end
