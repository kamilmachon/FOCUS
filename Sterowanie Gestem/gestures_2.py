import cv2
import math
import numpy as np

# Gestures on bigger ROI

cap = cv2.VideoCapture(0)

while (cap.isOpened()):
    # get image from camera
    _, img = cap.read()

    # size, not really necessary
    #height = np.size(img, 0)
    #width = np.size(img, 1)
    #print "height = ", height
    #print "width = ", width

    # define region of image and draw it on image
    roi = img # [10:470, 10:500]

    # why the fuck is it crucial
    cv2.rectangle(img, (640, 480), (0, 0), (100, 200, 100), 0)

    # convert to grayscale and binarize
    grey = cv2.cvtColor(roi, cv2.COLOR_BGR2GRAY)
    blurred = cv2.GaussianBlur(grey, (35, 35), 0)  # 35x35 mask
    _, binary = cv2.threshold(blurred, 127, 255, cv2.THRESH_BINARY_INV + cv2.THRESH_OTSU)
                                                # cv2.THRESH_BINARY_INV for bright background
                                                # cv2.THRESH_BINARY_    for dark background

    # contours
    img2, contours, hierarchy = cv2.findContours(binary, cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)
                                                   # what do those parameters do (???????????????)
    cnt = max(contours, key=lambda x: cv2.contourArea(x)) # contour with biggest area

    # moments of image, center
    M = cv2.moments(cnt)
    if M['m00']==0: M['m00']=1
    cx = int(M['m10']/M['m00'])
    cy = int(M['m01']/M['m00'])

    # hull
    hull = cv2.convexHull(cnt)

    # solidity
    hull_area = cv2.contourArea(hull)
    area = cv2.contourArea(cnt)
    solidity = float(area) / hull_area

    # convexity defects - points between fingers
    hull2 = cv2.convexHull(cnt, returnPoints=False)
    defects = cv2.convexityDefects(cnt, hull2)
    count_defects = 0

    # new image with contour, center, conv. defects etc.
    black = np.zeros(roi.shape, np.uint8)
        # contour of palm and hull
    cv2.drawContours(black, [cnt], 0, (0, 200, 0), 3)
    cv2.drawContours(black, [hull], 0, (0, 0, 255), 1)
        # circle in the middle
    cv2.circle(black, (cx, cy), 3, (255, 255, 0), 3)


    for i in range(defects.shape[0]):
        s,e,f,d=defects[i, 0]
        start = tuple(cnt[s][0]) # tuple is like a list
        end = tuple(cnt[e][0])
        far = tuple(cnt[f][0])

        # distances and cosine theorem
        a = math.sqrt((end[0] - start[0]) ** 2 + (end[1] - start[1]) ** 2)
        b = math.sqrt((far[0] - start[0]) ** 2 + (far[1] - start[1]) ** 2)
        c = math.sqrt((end[0] - far[0]) ** 2 + (end[1] - far[1]) ** 2)
        angle = math.acos((b ** 2 + c ** 2 - a ** 2) / (2 * b * c)) * 57 #why?

        # angles determining the detection
        if angle <= 90 and angle >= 10:
            count_defects += 1
            cv2.circle(black, far, 5, [255, 0, 0], -1)

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


    # lines for turning
    cv2.line(black, (200,0), (200,480), (255,255,255), 1)
    cv2.line(black, (440, 0), (440, 480), (255,255,255), 1)

    # left, right, stop
    if solidity > 0.7:
        cv2.putText(black, "STOP", (50, 50), cv2.FONT_HERSHEY_SIMPLEX, 2, (255, 255, 255), 2)
    elif cx < 160:
        cv2.putText(black, "TURN LEFT", (50, 50), cv2.FONT_HERSHEY_SIMPLEX, 2, (255,255,255), 2)
    elif cx > 160+170:
        cv2.putText(black, "TURN RIGHT", (50, 50), cv2.FONT_HERSHEY_SIMPLEX, 2, (255,255,255), 2)
    else:
        cv2.putText(black, "GO FORWARD", (50, 50), cv2.FONT_HERSHEY_SIMPLEX, 2, (255,255,255), 2)

    #cv2.imshow('Image from camera', img)
    #cv2.imshow('Image from camera', roi)

    cv2.imshow('Binary', binary)

    #cv2.imshow('Contours', black)

    # drawing on one figure
    all_img = np.hstack((black, roi))
    cv2.imshow('Everything', all_img)


    # ESC to exit
    k = cv2.waitKey(10)
    if k == 27:
        break

cap.release()
cv2.destroyAllWindows()