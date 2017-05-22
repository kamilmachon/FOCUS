import cv2
import numpy as np



cap = cv2.VideoCapture(0)
while( cap.isOpened() ) :
    ret, img = cap.read(0)
    x=300      #wspolrzedne piksela z ktorego pobieramy kolor
    y=300
    cv2.circle(img,(x,y),10,(120,120,120),1)
    color=img[x,y]
    print color
    t=15 # +\- do granicy koloru
    lower_range = np.array([color[0]-t, color[1]-t, color[2]-t], dtype=np.uint8)
    upper_range = np.array([color[0]+t, color[1]+t, color[2]+t], dtype=np.uint8)
    mask = cv2.inRange(img, lower_range, upper_range)

    cv2.putText(img,"press esc when ready, color from the circle will be extracted", (50,50), cv2.FONT_HERSHEY_COMPLEX, 0.5, 255)
    cv2.imshow('final', img)
    cv2.imshow('image', mask)
    k = cv2.waitKey(10)
    if(k == 27):
        break

while( cap.isOpened() ) :
    ret, img = cap.read(0)

    lower_range = np.array([color[0]-t, color[1]-t, color[2]-t], dtype=np.uint8)
    upper_range = np.array([color[0]+t, color[1]+t, color[2]+t], dtype=np.uint8)
    mask = cv2.inRange(img, lower_range, upper_range)
    cv2.imshow('image', img)

    im = mask
    ret, thresh = cv2.threshold(im, 127, 255, 0)
    im2,contours,hierarchy = cv2.findContours(thresh, 1, 2)
    contours = sorted(contours, key=cv2.contourArea, reverse = True)[:1] #sortowanie konturow
    ret, im = cv2.threshold(im, 255, 255, 0) # robie czarny obraz

    cnt = contours[0]
    cnt2=cnt
    M = cv2.moments(cnt2)       #liczenie momentow i wsp srodka masy
    cx = int(M['m10']/M['m00'])
    cy = int(M['m01']/M['m00'])

    cv2.drawContours(im, cnt, 0, (255,255,255), 3) #tylko najwiekszy kontur
    im=cv2.medianBlur(im,7)


    hull = cv2.convexHull(cnt)
    hull_area = cv2.contourArea(hull)
    area = cv2.contourArea(cnt)
    solidity = float(area)/hull_area
    cv2.circle(im,(cx,cy),10,(120,120,120),1)    #znznaczam srodek konturu
    cv2.rectangle(im,(250,150),(400,300),(120,120,120),1)
    cv2.drawContours(im, [hull], 0, (150,150,250), 3)



    cv2.imshow('final', im)
    if solidity>0.7:
        print 'stop!'
        if cx<250:
            print 'left'
        elif cx>400:
            print 'right'

    else:
        print 'go!'
        if cx<250:
            print 'left'
        elif cx>400:
            print 'right'


    k = cv2.waitKey(10)
    if(k == 27):
        break

cv2.destroyAllWindows()
