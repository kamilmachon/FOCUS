import cv2
import numpy as np

im = cv2.imread('book.jpg',0)
ret, thresh = cv2.threshold(im, 127, 255, 0)
im2,contours,hierarchy = cv2.findContours(thresh, 1, 2)
contours = sorted(contours, key=cv2.contourArea, reverse = True)[:1]
ret, im = cv2.threshold(im, 255, 255, 0) # robie czarny obraz

cnt = contours[0]
cv2.drawContours(im, [cnt], 0, (255,255,255), 3) #tylko najwiekszy kontur

cv2.imshow('output',im)
cv2.waitKey(0)
cv2.destroyAllWindows()

#zostaje nam sam najwiekszy kontur
