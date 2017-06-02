close all;
clear all;

load stereoParams;
left = imread('image21L.png');
right = imread('image21R.png');

ptCloud = make3D(left, right, stereoParams);
map1 = map(ptCloud, 'box', 5);

left = imread('image24L.png');
right = imread('image24R.png');

ptCloud = make3D(left, right, stereoParams);
map2 = map(ptCloud, 'box', 5);
mc = mapCombine(map1, map2);

ex = expol(mc);
