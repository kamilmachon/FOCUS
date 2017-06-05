
import cv2
import numpy as np
import math

def left():
    file = open('instrukcje.txt','w')
    file.write('10')
    file.close()
def right():
    file = open('instrukcje.txt','w')
    file.write('01')
    file.close()
def go():
    file = open('instrukcje.txt','w')
    file.write('11')
    file.close()
def stop():
    file = open('instrukcje.txt','w')
    file.write('00')
    file.close()

cap = cv2.VideoCapture(0)
while( cap.isOpened() ) :
    ret, img = cap.read(0)
    img = cv2.bilateralFilter(img,17,75,75)

    x=300
    y=300
    color = img[x,y]

    x2=350
    y2=350
    color2 = img[x2,y2]

    x3=350
    y3=300
    color3 = img[x3,y3]

    x4=325
    y4=325
    color4 = img[x4,y4]

    x5=328
    y5=269
    color5 = img[x5,y5]

    x6=300
    y6=350
    color6 = img[x6,y6]


    # print color
    t=10 # +\- do granicy koloru
    l=20
    lower_range = np.array([color[0]-l, color[1]-l, color[2]-l], dtype=np.uint8)
    upper_range = np.array([color[0]+t, color[1]+t, color[2]+t], dtype=np.uint8)
    mask1 = cv2.inRange(img, lower_range, upper_range)

    lower_range = np.array([color2[0]-l, color2[1]-l, color2[2]-l], dtype=np.uint8)
    upper_range = np.array([color2[0]+t, color2[1]+t, color2[2]+t], dtype=np.uint8)
    mask2 = cv2.inRange(img, lower_range, upper_range)

    lower_range = np.array([color3[0]-l, color3[1]-l, color3[2]-l], dtype=np.uint8)
    upper_range = np.array([color3[0]+t, color3[1]+t, color3[2]+t], dtype=np.uint8)
    mask3 = cv2.inRange(img, lower_range, upper_range)

    lower_range = np.array([color4[0]-l, color4[1]-l, color4[2]-l], dtype=np.uint8)
    upper_range = np.array([color4[0]+t, color4[1]+t, color4[2]+t], dtype=np.uint8)
    mask4 = cv2.inRange(img, lower_range, upper_range)

    lower_range = np.array([color5[0]-l, color5[1]-l, color5[2]-l], dtype=np.uint8)
    upper_range = np.array([color5[0]+t, color5[1]+t, color5[2]+t], dtype=np.uint8)
    mask5 = cv2.inRange(img, lower_range, upper_range)

    lower_range = np.array([color6[0]-l, color6[1]-l, color6[2]-l], dtype=np.uint8)
    upper_range = np.array([color6[0]+t, color6[1]+t, color6[2]+t], dtype=np.uint8)
    mask6 = cv2.inRange(img, lower_range, upper_range)

    mask = mask1+mask2+mask3+mask4+mask5+mask6

    cv2.circle(img,(x,y),10,(120,120,120),1)
    cv2.circle(img,(x2,y2),10,(120,120,120),1)
    cv2.circle(img,(x3,y3),10,(120,120,120),1)
    cv2.circle(img,(x5,y4),10,(120,120,120),1)
    cv2.circle(img,(x5,y5),10,(120,120,120),1)
    cv2.circle(img,(x6,y6),10,(120,120,120),1)

    cv2.putText(img,"press esc when ready, color from the circle will be extracted", (50,50), cv2.FONT_HERSHEY_COMPLEX, 0.5, 255)
    cv2.imshow('image', img)
    cv2.imshow('mask', mask)
    k = cv2.waitKey(10)
    if(k == 27):
        break

cv2.destroyAllWindows()

while( cap.isOpened() ) :
    ret, img = cap.read(0)
    #img2=img
    img = cv2.bilateralFilter(img,17,75,75)

    lower_range = np.array([color[0]-l, color[1]-l, color[2]-l], dtype=np.uint8)
    upper_range = np.array([color[0]+t, color[1]+t, color[2]+t], dtype=np.uint8)
    mask1 = cv2.inRange(img, lower_range, upper_range)

    lower_range = np.array([color2[0]-l, color2[1]-l, color2[2]-l], dtype=np.uint8)
    upper_range = np.array([color2[0]+t, color2[1]+t, color2[2]+t], dtype=np.uint8)
    mask2 = cv2.inRange(img, lower_range, upper_range)

    lower_range = np.array([color3[0]-l, color3[1]-l, color3[2]-l], dtype=np.uint8)
    upper_range = np.array([color3[0]+t, color3[1]+t, color3[2]+t], dtype=np.uint8)
    mask3 = cv2.inRange(img, lower_range, upper_range)

    lower_range = np.array([color4[0]-l, color4[1]-l, color4[2]-l], dtype=np.uint8)
    upper_range = np.array([color4[0]+t, color4[1]+t, color4[2]+t], dtype=np.uint8)
    mask4 = cv2.inRange(img, lower_range, upper_range)

    lower_range = np.array([color5[0]-l, color5[1]-l, color5[2]-l], dtype=np.uint8)
    upper_range = np.array([color5[0]+t, color5[1]+t, color5[2]+t], dtype=np.uint8)
    mask5 = cv2.inRange(img, lower_range, upper_range)

    lower_range = np.array([color6[0]-l, color6[1]-l, color6[2]-l], dtype=np.uint8)
    upper_range = np.array([color6[0]+t, color6[1]+t, color6[2]+t], dtype=np.uint8)
    mask6 = cv2.inRange(img, lower_range, upper_range)

    mask = mask1+mask2+mask3+mask4+mask5+mask6


    kernel = np.ones((5,5),np.uint8)
    erode=cv2.erode(mask,kernel)
    kernel_2 = np.ones((9,9),np.uint8)
    mask=cv2.dilate(erode,kernel_2)
    cv2.imshow('masksds', mask)

    im2,contours,hierarchy = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    contours = sorted(contours, key=cv2.contourArea, reverse = True)[:1] #sortowanie konturow
    _,im = cv2.threshold(mask, 255, 255, 0) # robie czarny obraz

    cnt = contours[0]
    cnt2=cnt
    M = cv2.moments(cnt2)       #liczenie momentow i wsp srodka masy
    if M['m00']==0: M['m00']=1
    cx = int(M['m10']/M['m00'])
    cy = int(M['m01']/M['m00'])

    #kontur na obrazie binarnym
    cv2.drawContours(im, [cnt], 0, (255,255,255), 3) #tylko najwiekszy
    cv2.drawContours(img, [cnt], 0, (0,255,0), 2)
    im=cv2.medianBlur(im,7)

    #solidity, mozna wyeliminowac dodajac gest
    hull = cv2.convexHull(cnt)
    hull_area = cv2.contourArea(hull)
    area = cv2.contourArea(cnt)
    solidity = float(area)/hull_area

    #returnPoints=False sprawia, ze funkcja zwraca wspolrzedne punktow
    #o duzej "krzywiznie"
    hull2 = cv2.convexHull(cnt, returnPoints=False)
    defects = cv2.convexityDefects(cnt2, hull2)
    count_defects=0

    for i in range(defects.shape[0]):
        s,e,f,d=defects[i, 0]
        start = tuple(cnt[s][0]) #tuple to cos jak lista
        end = tuple(cnt[e][0])
        far = tuple(cnt[f][0])

        #twierdzenie cosinusow, a potem obliczenie kata
        a = math.sqrt((end[0] - start[0]) ** 2 + (end[1] - start[1]) ** 2)
        b = math.sqrt((far[0] - start[0]) ** 2 + (far[1] - start[1]) ** 2)
        c = math.sqrt((end[0] - far[0]) ** 2 + (end[1] - far[1]) ** 2)
        angle = math.acos((b ** 2 + c ** 2 - a ** 2) / (2 * b * c)) * 57 #why?

        #prawdopodobnie <=90 by zliczac rozgalezienia palcow, wtedy je zaznacza
        if angle <= 90:
            count_defects += 1
            cv2.circle(img, far, 5, [0, 0, 255], -1)

        #cv2.line(roi, start, end, [0, 255, 0], 2)

    if count_defects == 1:
        cv2.putText(img, "Gest1", (50, 50), cv2.FONT_HERSHEY_SIMPLEX, 2, 2)
    elif count_defects == 2:
        cv2.putText(img, "Gest2", (50, 50), cv2.FONT_HERSHEY_SIMPLEX, 2, 2)
    elif count_defects == 3:
        cv2.putText(img, "Gest3", (50, 50), cv2.FONT_HERSHEY_SIMPLEX, 2, 2)
    elif count_defects == 4:
        cv2.putText(img, "Gest4", (50, 50), cv2.FONT_HERSHEY_SIMPLEX, 2, 2)
    else:
        cv2.putText(img, "Gest5", (50, 50), cv2.FONT_HERSHEY_SIMPLEX, 2, 2)

    #srodek konturu
    cv2.circle(im,(cx,cy),10,(200,200,200),-1)
    cv2.putText(im, "center", (cx - 20, cy - 20), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 1)

    #prostokat na srodku
    cv2.rectangle(im,(250,150),(400,300),(120,120,120),1)
    cv2.drawContours(im, [hull], 0, (150,150,250), 2)

    cv2.imshow('Wprost z kamery', img) #wprost z kamery
    cv2.imshow('Osobne kontury', im)

    (x,y),(MA,ma),angle = cv2.fitEllipse(cnt)
    if angle>40 and angle<70:
        print angle
        right()
    elif angle>120 and angle<150:
        print angle
        left()
    else:
        if solidity>0.7:
            stop()
        else:
            print 'go!'
            if cx<250:
                print angle
                left()
            elif cx>400:
                print angle
                right()
            else:
                go()


    k = cv2.waitKey(10)
    if(k == 27):
        break

cv2.destroyAllWindows()
