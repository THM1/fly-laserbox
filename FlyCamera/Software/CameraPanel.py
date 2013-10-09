#!/usr/bin/env python
import cv
import wx
import time
import math
from Recorder import *

# http://opencv.willowgarage.com/wiki/wxpython
#class CameraPanel(wx.Panel):
#http://wiki.wxpython.org/BufferedCanvas
class CameraPanel(wx.Panel):
	# If true, it shows the video
	#__showPreview = True
	# If true, this tab is selected
	#__tabSelected = True
	
	__text = "#"

	# Last frame to draw
	__lastBitmap = None

	__width = None
	__height = None

	#http://stackoverflow.com/questions/5732952/draw-on-image-buffer-memorydc-in-separate-thread
	def __init__(self,parent, width=320,height=240):
		wx.Panel.__init__(self,parent,wx.ID_ANY)
		self.SetSize((width, height))
		self.SetMinSize((width, height))
		self.__width = width
		self.__height = height
		#self.SetSize((int(640*0.5), int(480*0.5)))
		#self.SetMinSize((int(640*0.5), int(480*0.5)))
		#EVT_FRAME(self,self.OnFrame)]
		
		self.Bind(wx.EVT_PAINT, self.OnPaint)
		
	#__font = 
	def OnFrame(self, frame):
		'''Show Result status.'''
		
		#frame = event.data
		#if frame is None:
		#	return
		
		dc= wx.ClientDC(self)
		
		if frame.data is not None:
			# Does the image need to be rescaled?
			if (frame.width, frame.height) != (self.__width, self.__height):
				image = wx.ImageFromBuffer(frame.width, frame.height, frame.data)
				self.__lastBitmap = image.Rescale(self.__width, self.__height).ConvertToBitmap()
			else:
				self.__lastBitmap = wx.BitmapFromBuffer(frame.width, frame.height, frame.data)

		#if frame.bitmap is not None:
			dc.DrawBitmap(self.__lastBitmap, 0, 0);
		else:
			dc.SetBackground(	wx.MEDIUM_GREY_PEN	)
			dc.Clear()
		'''
		bitmap = wx.EmptyImage(frame.width, frame.height)
		bitmap.SetData(frame.tostring())
		
		self.data = wx.BitmapFromImage(image)
		'''
		
		
		
		dc.SetTextForeground(	(255,255,255)	)
		
		if frame.camera is not None:
			font = wx.Font(50, wx.FONTFAMILY_DEFAULT, wx.FONTSTYLE_NORMAL, wx.FONTWEIGHT_BOLD)
			dc.SetFont(font)
			dc.DrawText(self.__text + str(frame.camera), 10,10)
		#dc.DrawText(str(1), (bitmap.GetWidth() - 50)/ 2, (bitmap.GetHeight()-50) / 2)
		
		
		
		if frame.elapsedTime is not None:
			seconds = int(frame.elapsedTime % 60)
			minutes = int(math.floor((frame.elapsedTime % 3600 ) / 60))
			hours = int(math.floor(frame.elapsedTime / (60 * 60)))
			
			font = wx.Font(10, wx.FONTFAMILY_TELETYPE, wx.FONTSTYLE_NORMAL, wx.FONTWEIGHT_BOLD)
			dc.SetFont(font)
			dc.DrawText(str(hours) + ":" +str(minutes) + ":" + str(seconds), 10,self.__height - 30)
		
		if frame.fps is not None:
			font = wx.Font(10, wx.FONTFAMILY_TELETYPE, wx.FONTSTYLE_NORMAL, wx.FONTWEIGHT_BOLD)
			dc.SetFont(font)
			dc.DrawText("FPS: " + str(int(frame.fps)), 10,self.__height - 20)
			
		
		
		dc.Destroy()
	'''
	def SetShowPreview (self, show):
		self.__showPreview = show

	def GetShowPreview (self):
		return self.__showPreview
	
	def SetTabSelected (self, selected):
		self.__tabSelected = selected

	def GetTabSelected (self):
		return self.__tabSelected
	'''
	
	def ChangeWatermark (self, text):
		self.__text = text
		
	def OnPaint (self, event):
		#print "execution entered on_paint"
		dc= wx.PaintDC(self)
		dc.BeginDrawing()
		if self.__lastBitmap:
			dc.DrawBitmap(self.__lastBitmap, 0, 0);
		else:
			#dc.SetPen(wx.Pen( wx.Color(255,2550,0))	)
			dc.SetBrush(wx.Brush("#808080",style=wx.SOLID))
			(w,h) = dc.GetSize()
			dc.DrawRectangle(0,0,w,h)
		dc.Destroy()
		
#http://wiki.wxpython.org/LongRunningTasks
# Define notification event for thread completion
'''
EVT_FRAME_ID = wx.NewId()

def EVT_FRAME(win, func):
	#Define Result Event.
	win.Connect(-1, -1, EVT_FRAME_ID, func)
'''
#class FrameEvent(wx.PyEvent):
class FrameEvent:
	data = None
	
	width = None
	height = None
	depth = None
	channels = None
	
	elapsedTime = None;
	camera = None;
	fps = None
	
	
	
	'''Simple event to carry arbitrary result data.'''
	def __init__(self, frame, camera=None, startTime=None, fps=None):
		'''Init Result Event.'''
		#wx.PyEvent.__init__(self)
		#self.SetEventType(EVT_FRAME_ID)
		#self.data = frame
		
		self.camera = camera
		self.fps = fps
		
		# Start time may not be provided.
		# In un-continuous streaming (for instance when frame polling)
		# it has in fact no meaning.
		# Setting the elapsedTime to None,
		# we indicate to the CameraPanel not to display
		# any time on the rendered frame.
		if startTime is not None:
			self.elapsedTime = time.time() - startTime
		#	self.elapsedTime = None
		#else:
			
			
			
				
		if frame is None:
			#self.data = None
			return
		
		a = 0.5
		self.width= int(frame.width*a)
		self.height = int(frame.height*a)
		
		self.depth = frame.depth
		self.channels = frame.nChannels
		
		#print camera, ": ", newWidth, " ", newHeight
		#print camera, ": ", frame.width, " ", frame.height, " (raw"
		
		#if self.__frameBuffer == None:
		
		
		frameBuffer = cv.CreateImage((self.width, self.height), frame.depth, frame.nChannels)		
		cv.Resize(frame, frameBuffer)
		#cv.PyrDown(frame, frameBuffer)
		
		#http://abstract.cs.washington.edu/~shwetak/classes/cse599u/notes/CV.pdf
		
		
		
		#print frame
		#print self.__frameBuffer
		#print "\t"
		
		# http://wiki.wxpython.org/WorkingWithImages
		cv.CvtColor(frameBuffer, frameBuffer, cv.CV_BGR2RGB)
		
		
		'''
		image = wx.EmptyImage(frameBuffer.width, frameBuffer.height)
		image.SetData(frameBuffer.tostring())
		self.data = wx.BitmapFromImage(image)
		'''
		#self.data = frameBuffer
		self.data = frameBuffer.tostring()
		
		
		#print startTime
		
		# Camera
		
		#time.sleep(0)
