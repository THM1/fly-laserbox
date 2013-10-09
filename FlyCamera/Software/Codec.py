import cv


#class Codec:
#http://stackoverflow.com/questions/6852016/how-do-you-set-the-frame-size-of-cv-createvideowriter
#http://www.cs.iit.edu/~agam/cs512/lect-notes/opencv-intro/
#http://www.fourcc.org/codecs.php
#http://opencv.willowgarage.com/wiki/VideoCodecs
codecArray = [
	(cv.CV_FOURCC('P', 'I', 'M', '1'),	"PIM1 (MPEG-1)"	),	# MPEG-1 codec		# Windows ?,	ArchLinux NOT
	(cv.CV_FOURCC('M', 'P', '4', '2'),	"MP43 (MPEG-4.2)"	),		# MPEG-4.2 codec	# Windows ?,	ArchLinux NOT
	(cv.CV_FOURCC('D', 'I', 'V', '3'),	"DIV3 (MPEG-4.3)"	),		# MPEG-4.3 codec	# Windows ?,	ArchLinux NOT
	(cv.CV_FOURCC('D', 'I', 'V', 'X'),	"DIVX (MPEG-4)"	),		# MPEG-4 codec		# Windows OK,	ArchLinux NOT
	(cv.CV_FOURCC('U', '2', '6', '3'),	"U263 (H263)"	),		# H263 codec		# Windows ?,	ArchLinux NOT
	(cv.CV_FOURCC('I', '2', '6', '3'),	"I263 (H263 I)"	),		# H263I codec		# Windows ?,	ArchLinux NOT
	(cv.CV_FOURCC('I', '2', '6', '3'),	"I263 (FLV1)"	),		# FLV1 codec		# Windows ?,	ArchLinux NOT
	(cv.CV_FOURCC('X', '2', '6', '4'),	"X264 (?)"	),		# ? codec			# Windows ?,	ArchLinux (cannot put pipeline to play)
	(cv.CV_FOURCC('M', 'P', '1', 'V'),	"MP1V (?)"	),		# ? codec			# Windows ?,	ArchLinux (cannot link elements)
	(cv.CV_FOURCC('I', '4', '2', '0'),	"I420 (?)"	),		# ? codec			# Windows ?,	ArchLinux NOT	
	(cv.CV_FOURCC('A', 'V', 'I', ' '),	"AVI"	),		# Ctrax?			# Windows ?,	ArchLinux NOT
	(cv.CV_FOURCC('D', 'I', 'B', ' '),	"DIB  (RGB-A)"	),		# RGB(A) codec		# Windows ?,	ArchLinux ?
	(cv.CV_FOURCC('I', '4', '2', '0'),	"I420 (RAW I420)"	),		# RAW I420			# Windows ?,	ArchLinux ?
	(cv.CV_FOURCC('I', 'Y', 'U', 'V'),	"IYUV (RAW I420)"	)		# RAW I420			# Windows ?,	ArchLinux ?
	]

# Position of this codec in the codec array
DIVX_INDEX = 3
AVI_INDEX = 10

#fourcc = -1,									#					# Windows OK,	ArchLinux NOT
#fourcc = cv.CV_FOURCC('P', 'I', 'M', '1'),		# MPEG-1 codec		# Windows ?,	ArchLinux NOT
#fourcc = cv.CV_FOURCC('P', 'I', 'M', '1'),		# MPEG-1 codec		# Windows ?,	ArchLinux NOT
#fourcc = cv.CV_FOURCC('M', 'P', '4', '2'),		# MPEG-4.2 codec	# Windows ?,	ArchLinux NOT
#fourcc = cv.CV_FOURCC('D', 'I', 'V', '3'),		# MPEG-4.3 codec	# Windows ?,	ArchLinux NOT
#fourcc = cv.CV_FOURCC('D', 'I', 'V', 'X'),		# MPEG-4 codec		# Windows OK,	ArchLinux NOT
#fourcc = cv.CV_FOURCC('U', '2', '6', '3'),		# H263 codec		# Windows ?,	ArchLinux NOT
#fourcc = cv.CV_FOURCC('I', '2', '6', '3'),		# H263I codec		# Windows ?,	ArchLinux NOT
#fourcc = cv.CV_FOURCC('I', '2', '6', '3'),		# FLV1 codec		# Windows ?,	ArchLinux NOT
#fourcc = cv.CV_FOURCC('X', '2', '6', '4'),		# ? codec			# Windows ?,	ArchLinux (cannot put pipeline to play)
#fourcc = cv.CV_FOURCC('M', 'P', '1', 'V'),		# ? codec			# Windows ?,	ArchLinux (cannot link elements)
#fourcc = cv.CV_FOURCC('I', '4', '2', '0'),		# ? codec			# Windows ?,	ArchLinux NOT	
#fourcc = cv.CV_FOURCC('A', 'V', 'I', ' '),		# Ctrax?			# Windows ?,	ArchLinux NOT
#fourcc = cv.CV_FOURCC('D', 'I', 'B', ' '),		# RGB(A) codec		# Windows ?,	ArchLinux ?
#fourcc = cv.CV_FOURCC('I', '4', '2', '0'),		# RAW I420			# Windows ?,	ArchLinux ?
#fourcc = cv.CV_FOURCC('I', 'Y', 'U', 'V'),		# RAW I420			# Windows ?,	ArchLinux ?
		