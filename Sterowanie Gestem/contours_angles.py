import cv2
import numpy as np
import math

cap = cv2.VideoCapture(0)
while (cap.isOpened()):
    ret, img = cap.read()
    cv2.rectangle(img, (300, 300), (100, 100), (0, 255, 0), 0)
    roi = img[100:300, 100:300] #roi z ktorego mozna czytac gesty
    grey = cv2.cvtColor(roi, cv2.COLOR_BGR2GRAY)

    blurred = cv2.GaussianBlur(grey, (35,35), 0) #rozmiar maski 35x35, stdev 0
    _,thresh1 = cv2.threshold(blurred, 127, 255, cv2.THRESH_BINARY_INV + cv2.THRESH_OTSU) #binaryzacja Otsu
    cv2.imshow('Thresholded', thresh1)

    #findContours(obraz, metoda wyszukiwania, metoda aproksymacji)
    #zwraca obraz, liste konturow (numpy arrays of coordinates),
    image,contours,_=cv2.findContours(thresh1.copy(), cv2.RETR_TREE, cv2.CHAIN_APPROX_NONE)

    #zwraca kontur o najwiekszej powierzchni (?)
    cnt = max(contours, key=lambda x: cv2.contourArea(x))

    #rysuje ograniczajacy prostokat
    x,y,w,h=cv2.boundingRect(cnt)
    cv2.rectangle(roi, (x, y), (x + w, y + h), (0, 255, 255), 0)
    #convexhull uwypukla wielokat
    hull = cv2.convexHull(cnt)

    #rysuje kontur reki i wielokata wypuklego wokol niej
    drawing = np.zeros(roi.shape, np.uint8)
    cv2.drawContours(drawing, [cnt], 0, (0, 255, 0), 0)
    cv2.drawContours(drawing, [hull], 0, (0, 0, 255), 0)

    #returnPoints=False sprawia, ze funkcja zwraca indeksy punktow w ktorych zachodzi 'hull'
    #czyli w punktach o duzej krzywiznie (pomiedzy palcami)
    hull = cv2.convexHull(cnt, returnPoints=False)

    defects = cv2.convexityDefects(cnt, hull)
    count_defects = 0
    cv2.drawContours(thresh1, contours, -1, (0, 255, 0), 3)

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
            cv2.circle(roi, far, 1, [0, 0, 255], -1)

        cv2.line(roi, start, end, [0, 255, 0], 2)

    if count_defects == 1:
        cv2.putText(img, "Gest1", (50, 50), cv2.FONT_HERSHEY_SIMPLEX, 2, 2)
    elif count_defects == 2:
        cv2.putText(img, "Gest2", (50, 50), cv2.FONT_HERSHEY_SIMPLEX, 1, 2)
    elif count_defects == 3:
        cv2.putText(img, "Gest3", (50, 50), cv2.FONT_HERSHEY_SIMPLEX, 2, 2)
    elif count_defects == 4:
        cv2.putText(img, "Gest4", (50, 50), cv2.FONT_HERSHEY_SIMPLEX, 2, 2)
    else:
        cv2.putText(img, "Gest5", (50, 50), cv2.FONT_HERSHEY_SIMPLEX, 2, 2)
    cv2.imshow('Gesture', img)
    all_img = np.hstack((drawing, roi))
    cv2.imshow('Contours', all_img)

    #wychodzenie escapem
    k = cv2.waitKey(10)
    if k == 27:
        break
cap.release()
cv2.destroyAllWindows()