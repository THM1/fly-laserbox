import cv2
from cv2 import cv
from Tracker import *

class PySoloTracker(Tracker):
    def __init__(self,xmlname):
        self.xmlname = xmlname
        
        # TEST
        #cv.NamedWindow("Tracked", 1)
         
    def doTrack(self,frame):
       
        
        return pos
    
    def drawDetectedFlies(self,frame, pos, color=None):

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

    #self.grabMovie = False
    #self.writer = None
    #self.cam = None
    
    self.arena = Arena(self)
    
    self.imageCount = 0
    self.lasttime = 0

    #self.maxTick = 60
    
    self.__firstFrame = True
    #self.tracking = True
    
    self.__tempFPS = 0 
    self.processingFPS = 0
    
    self.drawPath = False
    self.isSDMonitor = False

    def processFlyMovements(self):
        """
        Decides what to do with the data
        Called every frame
        """
        
        ct = self.getFrameTime()
        self.__tempFPS += 1
        delta = ( ct - self.lasttime)

        if delta >= 1: # if one second has elapsed
            self.lasttime = ct
            self.arena.compactSeconds(self.__tempFPS, delta) #average the coordinates and transfer from buffer to array
            self.processingFPS = self.__tempFPS; self.__tempFPS = 0
            
    def doTrack(self, frame, show_raw_diff=False, drawPath=True):
        """
        Track flies in ROIs using findContour algorithm in opencv
        Each frame is compared against the moving average
        take an opencv frame as input and return a frame as output with path, flies and mask drawn on it
        """
        track_one = True # Track only one fly per ROI

        # Smooth to get rid of false positives
        cv.Smooth(frame, frame, cv.CV_GAUSSIAN, 3, 0)

        # Create some empty containers to be used later on
        grey_image = cv.CreateImage(cv.GetSize(frame), cv.IPL_DEPTH_8U, 1)
        temp = cv.CloneImage(frame)
        difference = cv.CloneImage(frame)
        ROImsk = cv.CloneImage(grey_image)
        ROIwrk = cv.CloneImage(grey_image)

        if self.__firstFrame:
            #create the moving average
            self.moving_average = cv.CreateImage(cv.GetSize(frame), cv.IPL_DEPTH_32F, 3)
            cv.ConvertScale(frame, self.moving_average, 1.0, 0.0)
            self.__firstFrame = False
        else:
            #update the moving average
            cv.RunningAvg(frame, self.moving_average, 0.2, None) #0.04

        # Convert the scale of the moving average.
        cv.ConvertScale(self.moving_average, temp, 1.0, 0.0)

        # Minus the current frame from the moving average.
        cv.AbsDiff(frame, temp, difference)

        # Convert the image to grayscale.
        cv.CvtColor(difference, grey_image, cv.CV_RGB2GRAY)

        # Convert the image to black and white.
        cv.Threshold(grey_image, grey_image, 20, 255, cv.CV_THRESH_BINARY)

        # Dilate and erode to get proper blobs
        cv.Dilate(grey_image, grey_image, None, 2) #18
        cv.Erode(grey_image, grey_image, None, 2) #10

        #Build the mask. This allows for non rectangular ROIs
        for ROI in self.arena.ROIS:
            cv.FillPoly( ROImsk, [ROI], color=cv.CV_RGB(255, 255, 255) )
        
        #Apply the mask to the grey image where tracking happens
        cv.Copy(grey_image, ROIwrk, ROImsk)
        storage = cv.CreateMemStorage(0)

        #track each ROI
        for fly_number, ROI in enumerate( self.arena.ROIStoRect() ):
            
            (x1,y1), (x2,y2) = ROI
            cv.SetImageROI(ROIwrk, (x1,y1,x2-x1,y2-y1) )
            cv.SetImageROI(frame, (x1,y1,x2-x1,y2-y1) )
            cv.SetImageROI(grey_image, (x1,y1,x2-x1,y2-y1) )

            contour = cv.FindContours(ROIwrk, storage, cv.CV_RETR_CCOMP, cv.CV_CHAIN_APPROX_SIMPLE)

            points = []
            fly_coords = None

            while contour:
                # Draw rectangles
                bound_rect = cv.BoundingRect(list(contour))
                contour = contour.h_next()
                if track_one and not contour: # this will make sure we are tracking only the biggest rectangle
                    pt1 = (bound_rect[0], bound_rect[1])
                    pt2 = (bound_rect[0] + bound_rect[2], bound_rect[1] + bound_rect[3])
                    points.append(pt1); points.append(pt2)
                    cv.Rectangle(frame, pt1, pt2, cv.CV_RGB(255,0,0), 1)
                    
                    fly_coords = ( pt1[0]+(pt2[0]-pt1[0])/2, pt1[1]+(pt2[1]-pt1[1])/2 )
                    area = (pt2[0]-pt1[0])*(pt2[1]-pt1[1])
                    if area > 400: fly_coords = None

            # for each frame adds fly coordinates to all ROIS. Also do some filtering to remove false positives
            fly_coords, distance = self.arena.addFlyCoords(fly_number, fly_coords)

            frame = self.__drawCross(frame, fly_coords)
            if drawPath: frame = self.__drawLastSteps(frame, fly_number, steps=5)
            if show_raw_diff: grey_image = self.__drawCross(grey_image, fly_coords, color=(100,100,100))

            cv.ResetImageROI(ROIwrk)
            cv.ResetImageROI(grey_image)
            cv.ResetImageROI(frame)
            
        self.processFlyMovements()
        
        if show_raw_diff:
            temp2 = cv.CloneImage(grey_image)
            cv.CvtColor(grey_image, temp2, cv.CV_GRAY2RGB)#show the actual difference blob that will be tracked
            return temp2

        return frame
