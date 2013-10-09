'''
Created on 11 Jul 2012

@author: az611
'''
import threading
from Queue import *
from Tracker import *
import time

class TrackerQueue (threading.Thread):
    
    __tracker = None
    __queue = None
    
    __alive = True
    def __init__ (self, tracker, queueSize = 0):
        threading.Thread.__init__(self)
        
        self.__tracker = tracker
        self.__queue = Queue(queueSize)
    
    def AnalyseFrame (self, frame):
        newFrame = cv.CloneImage(frame)
        try :
            self.__queue.put(newFrame, False)
        except Full:
            # Skip the frame if the queue is empty
            return
    
    def run (self):
        while self.__alive:
            # Fetch a frame
            frame = None
            while ( frame is None   and
                    self.__alive        ):
                try:
                    frame = self.__queue.get(True, 1)
                except Empty:
                    frame = None
                    continue
            
            pos = self.__tracker.doTrack(frame)
            # Thread.yield()
            time.sleep(1)
            #print "aaa"
            
    def DestroyGently (self):
        self.__alive = False