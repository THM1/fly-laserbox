#!/usr/bin/env python
import cv
#import cv2
import wx
import threading
import multiprocessing
import time
import datetime
import psutil
import os
import sys

import datetime

from Codec import *
from FrameBuffer import *
from Database import *
from QRDecoder import *

from Tracker import *
from TrackerQueue import *



class VideoInput :
	inputSource = None

	width = None
	height = None

	lastFrame = None

	def __init__ (self, inputSource = None):
		self.inputSource = inputSource

	def StartInput (self, **params):
		pass

	def GetNextFrame (self):
		pass

	def GetWidth(self):		return self.width
	def GetHeight(self):	return self.height

	def Stop (self):
		pass

	def DestroyGently(self):
		self.height = None
		self.width = None
		self.lastFrame = None
		self.inputSource = None

class VideoInputFromCamera (VideoInput):
	#__camera = None
	capture = None

	def __init__ (self, camera):
		VideoInput.__init__(self, camera)

	def StartInput (self, **params):
		self.capture = cv.CreateCameraCapture(self.inputSource)
		cv.SetCaptureProperty(self.capture, cv.CV_CAP_PROP_FPS, params['fps'])
				
		self.width = int(cv.GetCaptureProperty(self.capture, cv.CV_CAP_PROP_FRAME_WIDTH))
		self.height = int(cv.GetCaptureProperty(self.capture, cv.CV_CAP_PROP_FRAME_HEIGHT))
		return self.width, self.height

	def GetNextFrame (self):
		self.lastFrame = cv.QueryFrame(self.capture)
		return self.lastFrame

	def DestroyGently(self):
		self.capture = None
		#super.DestroyGently()

	def Stop (self):
		self.capture = None

	def __str__( self ):
		return "Camera device " + str(self.inputSource)