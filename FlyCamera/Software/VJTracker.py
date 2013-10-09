import cv2
from cv2 import cv
from Tracker import *

class VJTracker(Tracker):
    def __init__(self,xmlname):
        Tracker.__init__()
        self.xmlname = xmlname

        
        # TEST
        #cv.NamedWindow("Tracked", 1)
         
    def doTrack(self,frame):
        '''
        Use Viola-Jones method detect flies in single frame
        '''
        grey = cv.CreateImage(cv.GetSize(frame), cv.IPL_DEPTH_8U, 1)
        cv.CvtColor(frame, grey, cv.CV_RGB2GRAY)
        storage = cv.CreateMemStorage(0)
        cv.EqualizeHist(grey, grey)
        cascade = cv.Load(self.xmlname)
        pos = cv.HaarDetectObjects(grey, cascade, storage, 1.1, 3,
                                cv.CV_HAAR_DO_CANNY_PRUNING, (30,30))
        
        
        # TEST
        #frame = self.drawDetectedFlies(frame, pos)
        #cv.ShowImage("Tracked", frame)
        #cv.WaitKey(0.01)
        
        return pos
    
    def drawDetectedFlies(self,frame, pos, color=None):

        for p in pos:
            x = p[0][0]+p[0][2]/2
            y = p[0][1]+p[0][3]/2

            # print [x,y]
            # The position detected by Viola-Jones is drawn as blue
            frame = self.drawCross(frame, (x, y), color)
        return frame
        '''
        print "Press any key to exit"
        cv.NamedWindow("Tracked", 1)
        cv.ShowImage("Tracked", frame)
        cv.WaitKey(-1)
        cv.DestroyWindow("Tracked")
        '''
            
    def drawCross(self, frame, pt, color=None, drawCoords=False):
        '''
        Draw a cross around a point pt
        '''
        if not color: color = (255,255,255)
        width = 1
        line_type = cv.CV_AA
        
        x, y = pt
        a = (x, y-5)
        b = (x, y+5)
        c = (x-5, y)
        d = (x+5, y)
        
        cv.Line(frame, a, b, color, width, line_type, 0)
        cv.Line(frame, c, d, color, width, line_type, 0)
        
        if drawCoords:
            font = cv.InitFont(cv.CV_FONT_HERSHEY_PLAIN, 1, 1, 0, 1, 8)
            textcolor = (255,255,255)
            text = "%02d, %02d" % (x, y)
            cv.PutText(frame, text, (x+10, y), font, textcolor)
        
        return frame
'''
if __name__ == '__main__':

    f_pos = 10
    filepath = 'E:/Dropbox/PG/IndiProject/Video/day_test_1.avi'
    source = cv.CaptureFromFile(filepath)
    cv.SetCaptureProperty(source, cv.CV_CAP_PROP_POS_FRAMES, f_pos)#CV_CAP_PROP_POS_FRAMES
    frame = cv.QueryFrame(source)
    t = Tracker('cascade500b.xml')
    pos = t.doTrack(frame)
    # print pos
    t.drawDetectedFlies(frame, pos)
'''