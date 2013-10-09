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

		
class BaseProcess(multiprocessing.Process):

	# When False, the process is requested for its termination
	__alive = True
	
	# Queue used to stream frames
	__outputLog = None
	# If true, it enables remote logs
	__enablePrintLog = False

	# Pipe used for the remote procedure call (parent process side)
	__serverChannel = None
	# Pipe used for the remote procedure call (child process side)
	__clientChannel = None


	# Indicates if this instance is the parent or the child
	__parentProcess = True
	

	def __init__(self, outputLog = None):
		multiprocessing.Process.__init__(self, name="PythonTracker")

		self.__outputLog = outputLog

		# Pipe for remote procedure call
		self.__serverChannel, self.__clientChannel = multiprocessing.Pipe()

	
	def IsParent(self):
		return self.__parentProcess;

	# Start services associated with this thread.
	def StartServices (self):
		# Remote call handler
		threadCall = threading.Thread(target=self.__remoteCallHandler, name="RPCThread")
		#threadCall.setDaemon(True)
		#threadCall.daemon = True
		threadCall.start()

		# Keep alive
		threadAlive = threading.Thread(target=self.__keepAliveHandler, name = "KeepAliveThread")
		threadAlive.setDaemon(True)
		threadAlive.daemon = True
		threadAlive.start()

		# Auxiliary services
		self.AuxiliaryServices();

	# The method runs every auxiliary function required,
	# when the process is started.
	def AuxiliaryServices (self):
		pass

	# This methods must be overwritten in order to
	# implement the logic of this process.
	def RunCycle (self):
		pass

	# The main code of the process
	# This code is executed in another process.
	def run (self):
		self.__parentProcess = False;

		# Start services
		self.StartServices();

		#while self.__alive:
		self.RunCycle()

		self.DestroyGently()
	
	# Send a message to the server log
	def PrintLog (self, *messages):
		if not self.__enablePrintLog:
			return;

		if self.__outputLog is None:
			return

		string = ""
		for message in messages:
			string = string + str(message)

		print "{LOCALE: ", os.getpid(), "}\t", string
		self.__outputLog.put(	"{REMOTE:  " + str(os.getpid()) + "}\t" + string	)

	# Let the thread die
	def DestroyGently (self, fakeArgument=None):
		# Prevent multiple closures
		if not self.__alive:
			return;

		self.__alive = False

		# Decides which resources to release
		if self.__parentProcess:
			self.__serverChannel.close();
		#else:
		#	self.__clientChannel.close();
		#	This one is closed when the RCP thread dies

		return True



	# This method must be invoked by the parent process only.
	# It will trigger a function to be called in the child process.
	def RemoteCallProcedure (self, methodToCall, *args):
		if not self.__parentProcess:
			# Error?
			return;

		#@TODO If shared between threads, a lock must be used!
		self.__serverChannel.send(	(methodToCall,) + args	)	# Join tuples
		return self.__serverChannel.recv()


	def __remoteCallHandler (self):
		while self.__alive:
			methodToCall = "---"
			try:
				# No requests
				if not self.__clientChannel.poll(1):
					continue
				
				if not self.__alive:
					break;
				
				# Read the request
				# It must be the name of the function to call
				#(methodName, args) = channel.recv()
				items = self.__clientChannel.recv()
				methodName = items[0]
				args = items[1:]	# () if no other arguments
				
				# http://stackoverflow.com/questions/3061/calling-a-function-from-a-string-with-the-functions-name-in-python
				#self.PrintLog("Remote procedure call: " + str(methodName) + ", args: " + str(args));
				methodToCall = getattr(self, methodName)
				result = methodToCall(*args)
				self.__clientChannel.send(result)
			except Exception, e:
				
				#self.DestroyGently()
				self.PrintLog("Captured Exception in [__remoteCallHandler] during [" + str(methodName) + "]:\t" + str(e))
				self.__clientChannel.send(None)
				#break
		# The server channel is not closed here.
		# "DestroyGently" must be invoked for this.
		
		# Channel closure
		try:
			self.__clientChannel.close()
		except Exception, e:
			self.PrintLog("Captured Exception in [__remoteCallHandler] during closure:\t" + str(e))
		#except IOError, e:
		#	# If the master pipe is broken, there is no reason to keep this alive
		#	self.terminate()


	def __keepAliveHandler (self):
		me = psutil.Process(	os.getpid()	)
		while self.__alive:
			try:
				# The parent is died
				parent = me.parent
				psutil.STATUS_DEAD
				if (		parent is None
						or	parent.status == psutil.STATUS_DEAD	):
					
					#self.__alive = False
					self.DestroyGently()
					self.PrintLog("Parent is dead! Request for termination...")
					#self.TerminateProcess()	# Windows
					return;
					#self.terminate()		# UNIX
				#self.__outputLog.put(	"PPID: " + str(parent.status	)	)
				time.sleep(1)
			except Exception, e:
				self.PrintLog("Captured Exception in [__keepAliveHandler]:\t" + str(e))