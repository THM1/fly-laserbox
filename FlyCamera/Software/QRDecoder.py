'''
Created on 3 Jul 2012

@author: az611
'''

#import sys
#import os
#sys.path.append(os.getcwd())
#print os.getcwd()
#print sys.path

import zbar
import cv

def decodeFromCameraFrame (frame) :
    #width, height = cv.GetSize(frame)
    
    # String -> IPL (colour)
    #framergb = cv.CreateImage((frame.width, frame.height), frame.depth, frame.channels)#.
    #cv.SetData(framergb, frame.data)
    
    # IPL (colour) -> IPL (bw)
    framebw = cv.CreateImage((frame.width, frame.height), cv.IPL_DEPTH_8U, 1);
    cv.CvtColor(frame, framebw, cv.CV_BGR2GRAY)
    #cv.ShowImage("a", framebw)
    # IPL (bw) -> ZbarImage (bw)
    image = zbar.Image(framebw.width, framebw.height, 'Y800', framebw.tostring())
    
    # scan the image for barcodes
    scanner = zbar.ImageScanner()
    scanner.parse_config('enable')
    scanner.scan(image)
    
    #cv.NamedWindow("w1", cv.CV_WINDOW_AUTOSIZE)
    #cv.ShowImage("w1", framebw)
    
    #cv.SaveImage("./test.jpg", framebw);
   
    # extract results
    #for symbol in image:
    #    # do something useful with results
    #    print 'decoded', symbol.type, 'symbol', '"%s"' % symbol.data
    return image