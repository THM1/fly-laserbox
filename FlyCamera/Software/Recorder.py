#!/usr/bin/env python
import cv
import wx
import threading
import multiprocessing
import time
import datetime
import psutil
import os
import sys
import traceback

from Codec import *
from CameraPanel import *
from FrameBuffer import *
from Database import *
from QRDecoder import *
from Tracker import *
from TrackerQueue import *
from VideoInput import *
from BaseProcess import *
		

class Recorder(BaseProcess):
	############################################################
	### INPUT
	############################################################

	# The name of the source the recorder is streaming from.
	# It can be the number of the device (if it is a camera)
	# or the name a file
	__inputSource = None

	# The VideoInput object that is going to perform the streaming
	__videoInput = None


	############################################################
	### OUTPUT
	############################################################

	# The FrameBuffer to save frames on a file
	__frameBuffer = None
	# Size of the buffer (in seconds of video with the current fps)
	__bufferTimeLength = 5

	# File where the video is going to be saved
	# This is the base name of the folder:
	# the progam will organise files in a special
	# folder structure. Such as "/2012/07/21/"
	__outputBaseFolder = None
	# Parth (folder+name) of the recording file
	__outputPath = None
	

	############################################################
	### PREVIEW
	############################################################

	# The CameraPanel to update
	__cameraPanel = None
	
	# How many frames per seconds do we send to the CameraPanel?
	__previewFPS = 2
	
	# Pipe for preview of frames
	#__previewChannel = None
	# Pipe for preview of frames (parent side)
	__serverPreviewChannel = None
	# Pipe for preview of frames (process side)
	__clientPreviewChannel = None
	
	
	############################################################
	### CYCLE
	############################################################

	# Indicates if this thread is alive or not
	__alive = True

	# Indicates if the acquisition cycle is running or not
	__acquiring = False
	# Indicates if the recording cycle is running or not
	__recording = False
	

	# Time when the registration started
	# Or none if there we are not recording yet
	__startTime = None
	
	
	############################################################
	### VIDEO INFO
	############################################################

	# Tle last frame acquired
	__lastFrame = None
	
	# The codec used
	__codec = None
	
	# Video width (only when acquiring, otherwise None)
	__width = None
	# Video height (only when acquiring, otherwise None)
	__height = None
	
	
	# The desired number of FPS to stream and to save
	__desiredFPS = 30
	

	############################################################
	### DATABASE
	############################################################
	
	# The ID of the recoding entry in the databse
	__recordingID = None
	
	# Dictionary of info about the video
	__recordingData = None


	############################################################
	### VIDEO ANALYSIS
	############################################################
	
	# The tracker currently used (or None)
	__trackerQueue = None
	




	############################################################
	### METHODS
	############################################################

	#def __init__(self, outputLog, previewChannel):
	def __init__(self, outputLog):
		BaseProcess.__init__(self, outputLog)
	
		#self.__previewChannel = previewChannel
			
		self.__serverPreviewChannel, self.__clientPreviewChannel = multiprocessing.Pipe()

		self.start()
	

	# Starts/Stops the acquisition cycle
	def SetAcquire (self, acquire):
		# Start acquisition...
		if acquire:
			# ...if not already started
			if not self.__acquiring:
				self.__width, self.__height = self.__videoInput.StartInput(fps=self.__desiredFPS)
				'''
				# To stream at 120 fps
				# NB: cv.Show must be removed or fps won't be greater that 64!
				self.__width = int(640/2)
				self.__height = int(480/2)
				cv.SetCaptureProperty(self.__capture, cv.CV_CAP_PROP_FRAME_WIDTH, self.__width)
				cv.SetCaptureProperty(self.__capture, cv.CV_CAP_PROP_FRAME_HEIGHT, self.__height)
				'''
				self.PrintLog(	"Start acquiring from imput: "+ str(self.__videoInput)+ "\t(" + str(self.__width)+ "x"+ str(self.__height)+ ")"	)
			# First:	Creates the acquisition
			# Then:		Starts the cycle
			self.__acquiring = acquire
		else:
			# First:	Stops the cycle
			# Then:		Destroies the acquisition
			self.__acquiring = acquire

			self.PrintLog( "Stop acquiring from input: "+ str(self.__videoInput))
		
		return self.__acquiring
			
	
	#def SetRecording (self, (recording,)	):
	def SetRecording (self, recording):
		try:
			# Start the recording...
			if recording:
				# ...if not already recording
				if (	not self.__recording	and
							self.__acquiring		):
					# Generate a new name
					# and creates the relative folder path
					self.__outputPath = self.GenerateUniqueRecordingName(self.__outputBaseFolder)
					dirName = os.path.dirname(self.__outputPath)
					if not os.path.exists(dirName):
						os.makedirs(dirName)

					# Creates the output video
					writer = cv.CreateVideoWriter(
						filename=self.__outputPath,
						fourcc = self.__codec,
						fps=self.__desiredFPS,
						frame_size=(self.__width, self.__height),
						is_color=1)				
					self.__frameBuffer = FrameBuffer(writer, int(self.__bufferTimeLength * self.__desiredFPS), 1)
					self.__frameBuffer.start()

					# First:	Creates the recording
					# Then:		Start the cycle
					self.__startTime = time.time()
					self.__recording = recording
					
					self.PrintLog("Start recording from input: " + str(self.__videoInput)	)

					# Saves data on the database
					if self.__recordingData is None:
						self.__recordingData = {}
					self.SaveCurrentRecordingDataOnDB()
			else:
				# First:	Stops the cycle
				# Then:		Destroies the record
				if self.__recording:
					self.__recording = recording
					self.PrintLog( "Stop recording from input: " + str(self.__videoInput))
					
					# Update information on the database
					self.UpdateCurrentRecordingDataOnDB()

					# Destroies data
					#if self.__frameBuffer:
					self.__frameBuffer.DestroyGently()
					self.__frameBuffer = None
					
					self.__recordingData = None
					self.__recordingID = None
					self.__outputPath = None
					self.__startTime = None
			
			return self.__recordingData
		except Exception, e:
			self.PrintLog("Error captured in 'SetRecording': ", str(e))
			#print traceback.format_exc()
			return None
	
	
	
	############################################################
	### SETTER
	############################################################
	def SetCodec (self, codec	):
		self.__codec = codec
		return self.__codec
	
	# Change the camera
	def SetCamera (self, camera):
		self.__inputSource = camera
		self.__videoInput = VideoInputFromCamera(camera)
		return camera
	
	def SetOutputBaseFolder (self, outputBaseFolder	):
		self.__outputBaseFolder = outputBaseFolder
		return self.__outputBaseFolder
	
	def GetLastFrame (self):
		return self.__lastFrame;

	def GetPreviewChannel(self):
		if self.IsParent():
			return self.__serverPreviewChannel
		else:
			return self.__clientPreviewChannel


	############################################################
	### DATABASE
	############################################################
	def SaveCurrentRecordingDataOnDB(self, **otherArgs):
		# They might be overwritter by "otherArgs"		
		if 'date' not in self.__recordingData:
			self.__recordingData['date'] = str(datetime.datetime.now())
			#print str(datetime.datetime.now())
			#self.__recordingData['date'] = str(datetime.date.today())
		if 'name' not in self.__recordingData:
			self.__recordingData['name'] = os.path.basename(self.__outputPath)
			#self.__recordingData['name'] = 'Video ' + str(datetime.date.today())
		if 'path' not in self.__recordingData:
			self.__recordingData['path'] = self.__outputPath
			#os.path.abspath(self.__outputBaseFolder)
		if 'codec' not in self.__recordingData:
			self.__recordingData['codec'] = self.__codec
		if 'comments' not in self.__recordingData:
			self.__recordingData['comments'] = 'Test!'
		
		# If we load info while not recording,
		# we skip the change of doing UPDATE since the row is not created yet.
		# To compensate, if there is a dictionary, on recording, it saves it too
		
		
		if len(otherArgs) != 0:
			self.__recordingData = dict(self.__recordingData, **otherArgs)

		self.__recordingID = SaveRecordingDataOnDB(**self.__recordingData)
		
	def UpdateCurrentRecordingDataOnDB(self, **otherArgs):
		self.__recordingData['length'] = time.time() - self.__startTime
		
		if len(otherArgs) != 0:
			self.__recordingData = dict(self.__recordingData, **otherArgs)
		
		UpdateRecordingDataOnDB(self.__recordingID, **self.__recordingData)




	def UpdateRecordingData (self, recordingData):
		if self.__recordingData is None:
			self.__recordingData = recordingData
			return
			
		self.__recordingData = dict(self.__recordingData, **recordingData)
	
	############################################################
	### QR CODE
	############################################################
	def LoadQRCodeIntoRecordingData (self, fakeArgument=None):
		result = decodeFromCameraFrame(self.__lastFrame)

		string = ""
		for code in result:
			string = string + str(code.data) + ';'
			#self.__printLog("Code found: ", code.data)
			self.PrintLog("Code found: ", code.data)

		# No QR code
		if len(string) == 0:
			return None
		# Removes the last ";" that was append in the previous cycle
		string = string[0:-1]
		
		dictionary = self.ExtractRecordingDataFromString(string)
		# Previous values from QRCODE are overwritten
		
		
		if dictionary is not None:
			if self.__recordingData is None:
				self.__recordingData = {}
			self.__recordingData = dict(self.__recordingData, **dictionary)
			
			if self.__recording:
				self.UpdateCurrentRecordingDataOnDB()
				# If it is not recording, update can't be called!
			
		return dictionary
	
	def ExtractRecordingDataFromString (self, codes):
		dictionary = {}
		properties = codes.split(';')
		for p in properties:
			info = p.split('=')
			if len(info) != 2:
				self.PrintLog("ERROR in 'ExtractInfoFromString', incorrect property: ", p)
				continue
			try:
				dictionary[str(info[0].strip())] = str(info[1]).strip()
			except KeyError, e:
				self.PrintLog("ERROR in 'ExtractInfoFromString': " + str(e)	)
		#print dictionary
		
		# No useful data
		if len(dictionary) == 0:
			return None
		return dictionary
	
	############################################################
	### RECORDING NAME
	############################################################
	# Given a folder, it generate an unique video name
	def GenerateUniqueRecordingName (self, basePath, baseName='Video'):
		dt = datetime.datetime.now()
		
		i = 0;
		nameFree = True
		path = None
		while nameFree:
			outputFolder = os.path.join(
				basePath,
				str(dt.year),
				str(dt.month)
				)
			outputName = baseName + '_' + str(dt.day) + '_' + str(dt.hour) + '-' + str(dt.minute) + '-' + str(dt.second) + '_' +str(i) +'.avi'
			
			path = os.path.join(outputFolder, outputName)
			nameFree = os.path.exists(path)
			
			i = i + 1
			
		return path




	############################################################
	### MAIN CYCLE
	############################################################

	# Connect to the database
	def AuxiliaryServices (self):
		ConnectToDatabase()

	# Reading cycle
	def RunCycle (self):		
		# NOT HERE------------------------
		# it is just for testing purposes
		'''
		tracker = Tracker('cascade500b.xml')
		self.__trackerQueue = TrackerQueue(tracker)
		self.__trackerQueue.start()
		'''
		
		#cv.NamedWindow("camera", 1)
		
		while self.__alive:
			# ----------------------------------------------------------
			# --- Wait for the video capture to start
			# ----------------------------------------------------------
			while (	not self.__acquiring
					and	self.__alive	):
				#pass
				time.sleep(1)
			
			if not self.__alive:
				break


			# ----------------------------------------------------------
			# --- Start acquisition cycle
			# ----------------------------------------------------------
			#width = int(cv.GetCaptureProperty(self.__capture, cv.CV_CAP_PROP_FRAME_WIDTH))
			#height = int(cv.GetCaptureProperty(self.__capture, cv.CV_CAP_PROP_FRAME_HEIGHT))
			#fps = 15#cv.GetCaptureProperty(capture, cv.CV_CAP_PROP_FPS)

			i = 0											# Frames acquired			
			previewTimeInterval = 1.0 / self.__previewFPS	#
			lastPreviewTime = 0								#
			cyclesAtLastPreview = 0							#
			start = time.time()								#
			wastedTime = 0									#

			while (		self.__acquiring
					and	self.__alive	):
				
				#self.__lastFrame = cv.QueryFrame(self.__capture)
				self.__lastFrame = self.__videoInput.GetNextFrame()

				'''
				# TRACKING! (OLD)
				tracker = Tracker('cascade500b.xml')
				pos = tracker.doTrack(self.__lastFrame)
				self.__lastFrame = tracker.drawDetectedFlies(self.__lastFrame, pos)
				'''
				
				if self.__lastFrame:
					# ----------------------------------------------------------
					# --- Video analysis
					# ----------------------------------------------------------
					if self.__trackerQueue:
						self.__trackerQueue.AnalyseFrame(self.__lastFrame)
					
					# ----------------------------------------------------------
					# --- Video output
					# ----------------------------------------------------------
					if self.__recording:
						self.__frameBuffer.WriteFrame(self.__lastFrame)

					# ----------------------------------------------------------
					# --- Video preview
					# ----------------------------------------------------------
					now = time.time()
					timeIntervalSinceLastPreview = now - lastPreviewTime
					previewChannel = self.GetPreviewChannel()
					if (	timeIntervalSinceLastPreview >= previewTimeInterval	and
							previewChannel is not None					) :
						try:
							# Are we ready for a new frame?
							if previewChannel.poll():
								wantsMoreFrame = previewChannel.recv()
								if wantsMoreFrame:
									fps = (i - cyclesAtLastPreview) / timeIntervalSinceLastPreview
									lastPreviewTime = now
									cyclesAtLastPreview = i
									previewChannel.send(	FrameEvent(self.__lastFrame, self.__inputSource, self.__startTime, fps)	)
						except IOError, e:
							self.PrintLog("Captured IOError: "+ str(e))
				
				# ----------------------------------------------------------
				# --- Real FPS calculation
				# ----------------------------------------------------------
				checkEverySeconds = 1
				checkEveryCycles = int(checkEverySeconds * self.__desiredFPS)
				if i % checkEveryCycles == 0:
					# In seconds
					idealCycleTime = 1.0 / self.__desiredFPS
					idealTimeSpent = idealCycleTime * checkEveryCycles

					# Real time spent
					now = time.time()
					realTimeSpent = now - start
					wastedTime = realTimeSpent - idealTimeSpent
					#print "Wasted: ", wastedTime, "\t", (realTimeSpent - idealTimeSpent), "\t(Ideal: ", idealTimeSpent, ", \tReal: ", realTimeSpent, ")" 
					start = now
					
					if realTimeSpent != 0:
						fps = checkEveryCycles / realTimeSpent
						#self.PrintLog(	"[" + str(self.__camera) + " TRACKER]\tFps: "+ str(fps)+ "\tTime: "+ str(realTimeSpent)	)
						
				cv.WaitKey(1)
				#time.sleep(0)
				
				i = i+1
			
			# Acquisitin cycle ended
			self.__lastFrame = None
			self.__width = None
			self.__height = None
			self.__videoInput.Stop()

		# Recorder thread ended
		self.__videoInput.DestroyGently()
		self.__videoInput = None

	# Let the thread die
	def DestroyGently (self, fakeArgument=None):
		# Prevent multiple closures
		if not self.__alive:
			return;
		
		if self.IsParent():
			# Remotely invoke the destroyer method on the child process
			self.RemoteCallProcedure("DestroyGently", None)
		else:
			self.SetRecording(False)
			self.SetAcquire(False)
		
		super(Recorder,self).DestroyGently()

		self.__alive = False
		return True