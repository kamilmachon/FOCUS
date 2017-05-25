import cv2
import numpy as np
import math
import argparse
import imutils

cap = cv2.VideoCapture(0)

while (cap.isOpened()):
    _,img = cap.read()
    img=img[100:400, 100:600]
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

    med = cv2.medianBlur(gray, 15)
    _,thresh = cv2.threshold(med, 70, 255, cv2.THRESH_BINARY_INV + cv2.THRESH_OTSU)

    cnts = cv2.findContours(thresh.copy(), cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    cnts = cnts[0] if imutils.is_cv2() else cnts[1]

    for c in cnts:
        # compute the center of the contour
        M = cv2.moments(c)
        if M["m00"]==0: M["m00"]=1
        cX = int(M["m10"] / M["m00"])
        cY = int(M["m01"] / M["m00"])

        # draw on the image
        cv2.drawContours(img, [c], -1, (0, 255, 0), 2)
        cv2.circle(img, (cX, cY), 7, (255, 255, 255), -1)
        cv2.putText(img, "center", (cX - 20, cY - 20), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 2)

    #calculate and print length
    len=int(math.sqrt( (cX-250)*(cX-250) + (cY-150)*(cY-150) ) )
    length=str(len)
    cv2.putText(img, "length:", (20, 20), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 1)
    cv2.putText(img, length, (80, 20), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 1)

    #calculate and print angle
    if (cX-250)==0: cX=251
    ang = int(-math.atan2((cY-150),(cX-250)) * 180 / math.pi)
    angle=str(ang)
    cv2.putText(img, "angle:", (20, 50), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 1)
    cv2.putText(img, angle, (80, 50), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 1)

    cv2.putText(img, "put me down, please", (20, 80), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 1)

    #print center and line
    cv2.circle(img, (250, 150), 7, (255, 0, 0), -1)
    cv2.line(img,(250,150),(cX,cY),(0,255,255),1)

    cv2.imshow('Org',img)
    cv2.imshow('med', thresh)

    k = cv2.waitKey(10)
    if k == 27:
        break

cap.release()
cv2.destroyAllWindows()