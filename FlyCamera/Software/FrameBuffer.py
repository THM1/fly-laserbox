#!/usr/bin/env python
import cv
import time
import threading

class FrameBuffer(threading.Thread):
	
	# When false, this buffer ends and flushes
	__alive = True




	# The buffer
	__buffer = None
	# Max size of the buffer
	__maxBufferSize = None
	
	# Moderates the access to the buffer
	__cv = threading.Condition()



	# Where to save frames
	__writer = None

	# Last time in which the buffer was flushed
	__lastFlushTime = None
	
	# After this time, it flush the buffer automatically
	# CURRENTLY NOT IMPLEMENTED!
	__maxFlushDelay = None
	
	
	
	
	
	def __init__(self, writer, maxBufferSize, maxFlushDelay):
		threading.Thread.__init__(self)
		
		self.__writer = writer
		self.__buffer = [];
		self.__lastFlushTime = time.time()
		self.__maxBufferSize = maxBufferSize
		self.__maxFlushDelay = maxFlushDelay
	
	def run (self):
		while self.__alive:
			# Waits for the buffer to be full
			self.__cv.acquire()
			while (	not self.__bufferFull()
					and	self.__alive		):
				self.__cv.wait(1)
			
			interval = time.time() - self.__lastFlushTime;
			fps = (len(self.__buffer) / interval)
			
			oldBuffer = self.__buffer
			self.__buffer = []
			self.__lastFlushTime = time.time()
			
			self.__cv.release()
			time.sleep(0)
			
			for frame in oldBuffer:
				cv.WriteFrame(self.__writer, frame)
				time.sleep(0)
			
			
			
	def __bufferFull (self):
		return len(self.__buffer) >= self.__maxBufferSize
	
	def WriteFrame (self, frame):
		# Copy the frame
		newFrame = cv.CloneImage(frame)
		
		self.__cv.acquire()
		
		self.__buffer.append(newFrame)
		
		flushed = False
		
		if self.__bufferFull():
			self.__cv.notify()
			flushed = True
		self.__cv.release()
		
		return flushed

	
	def DestroyGently(self):
		self.__alive = False