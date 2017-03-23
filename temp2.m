clear all;
close all;
vid = videoinput(costam);
vid.FramesPerTrigger=Inf;
vid.ReturnedColorSpace='rgb'; %format rgb
%vid.FrameGrabInterval=5; %co 5 klatke czyta
start(vid);
figure();
O=zeros(15,2)
iterator=1;

while(vid.FramesAcquired<100)
    data=getsnapshot(vid);
    %%
    %imshow(data);
    R=data(:,:,2); %czyta zielony
    R2=imsubtract(R, rgb2gray(data)); %kasuje wszystkie poza R czyli zielonym
    R3=medfilt2(R2,[3,3]);
    %R4=imadjust(R3);
    
    lv=graythresh(R3);
    BW=im2bw(R3,lv);
    BW2=imclose(BW, strel('disk', 5));
    BW3=imopen(BW2, strel('disk', 3));
    BW4=bwareaopen(BW3, 200);
    imshow(data);
    hold on
    cc=bwconncomp(BW4, 4)
    stats=regionprops(cc, 'basic') %daje strukture, 'basic' czyli podstawowe informacje o obrazku
    areas=[stats.Area];
    [max_a idx]=max(areas);
    rectangle('Position', [stats(idx).BoundingBox], 'EdgeColor', 'r');
    pos=[stats(idx).Centroid];
    O(iterator,:)=pos;
    iterator=iterator+1;
    if(iterator >= 15)
        iterator=1;
    end
    plot(O(:,1),O(:,2),'mh');
    hold off
    %%
end
stop(vid);