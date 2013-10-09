#!/usr/bin/env python

#import cv
import wx
import multiprocessing
import Queue
from Queue import *
import threading

#import threading
#import time

from MainFrame import *
from Database import *
#from Recorder import *
#from RecorderPanel import *

class MainApp(wx.App):
	
	__alive = True;
	
	__recorders = None
	__recorderPanels = None
	
	def OnInit(self):
		
		
		ConnectToDatabase()
		
		wx.InitAllImageHandlers()
		frame_1 = MainFrame(None, self)
		self.SetTopWindow(frame_1)
		
		
		#print "MAIN PID: " , os.getpid()
		
		#recorder = Recorder(0, "./output_1.avi")
		
		#array = [(0,"./output0"),(1,"./output1"),(2,"./output2"),(3,"./output3")]
		#array = [0,1,2,3]
		#array = [0,1]
		array = [0,1]
		self.__recorders = []
		self.__recorderPanels = []
		
		outputLog = multiprocessing.Queue();
		
		#for (camera,output) in array:
		for camera in array:
			#serverChannel, clientChannel = multiprocessing.Pipe()	# For RPC
			#serverPreview, clientPreview = multiprocessing.Pipe()	# For frame preview into wt
			#recorder = Recorder(outputLog, clientChannel, clientPreview)
			recorder = Recorder(outputLog)
			self.__recorders.append(recorder)
			
			#recorderPanel = RecorderPanel(camera, frame_1.notebook)
			#recorderPanel = RecorderPanel(camera, frame_1.contentPanel)
			#recorderPanel = RecorderPanel(camera, None)#frame_1.contentPanel)
			#recorderPanel.SetRecorder(recorder, serverPreview)

			#self.__recorderPanels.append(recorderPanel)

			#recorderPanel.SetRecorder(serverChannel, serverPreview)
			
			#recorderPanel.SetChannel(serverChannel);
			#frame_1.AddRecorderPanel(recorderPanel, "Stream " + str(camera) )
			recorderPanel = frame_1.AddRecorder(recorder, "Recorder " + str(camera) )
			self.__recorderPanels.append(recorderPanel)
		
		
		frame_1.SetSize((640,480))
		frame_1.Layout()
		frame_1.Show()

		
		# Thread that print output messages
		threadLog = threading.Thread(target=self.__printLog, args=(outputLog,), name="LogDaemon")
		#threadLog.setDaemon(True)
		#threadLog.daemon = True
		threadLog.start()
		#t1.join()
		
		return 1
		# end of class MainApp







	def __printLog (self, outputLog):
		while self.__alive:
			try:
				message = outputLog.get(True, 1)
			except Empty:
				continue
			except IOError, e:
				print "[Captured IOError in __printLog thread]: \t", e
				return;
			
			print "->\t", message
		# Closure
		print "__printLog channel closure..."
		try:
			outputLog.close()
		except IOError, e:
			print "[Captured IOError in __printLog thread during closure]: \t", e
	
	def DestroyGently (self):
		if not self.__alive:
			return;
		
		timeout = 2
		
		
		for recorderPanel in self.__recorderPanels:
			recorderPanel.DestroyGently()
			print "Destroied the trackerPanel "
			#print "All destroyed"
		#self.DestroyGently()
		for recorder in self.__recorders:
			recorder.join(timeout)
			print "Joined with tracker"
		
		#time.sleep(5)
		#self.__queue.close()
		#self.__queue.join_thread()
		#print "Joined with queue"
		self.__alive = False;
		#print "post self.DestroyGently()"
		print "Program terminated."
			

if __name__ == "__main__":
	app = MainApp(0)
	app.MainLoop()