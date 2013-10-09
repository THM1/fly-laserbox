'''
Created on 12 Jul 2012

@author: az611
'''
import wx
from QREncoder import *

class QRGeneratorPanel (wx.Panel):
    def __init__ (self, parent):
        wx.Panel.__init__(self, parent, wx.ID_ANY)
        
        
        sizer_0 = wx.BoxSizer(wx.VERTICAL)

        sizer_1 = wx.GridSizer(2,2,10,10);
        
        self.__cameras = []
        for _i in range (0,2):
            camera = CameraPanel(self, 640/3, 480/3)
            sizer_1.Add(camera)
            
            self.__cameras.append(camera)
        #print self.__cameras
        
        sizer_0.Add((10,10))
        sizer_0.Add(sizer_1)

        # Fit
        self.SetSizer(sizer_0)
        sizer_0.Fit(self)
        self.Layout()

        '''
        def showQRCode(self, filepath):
            img = wx.Image(filepath, wx.BITMAP_TYPE_ANY)
            # scale the image, preserving the aspect ratio
            W = img.GetWidth()
            H = img.GetHeight()

            if W > H:
                NewW = self.photo_max_size
                NewH = self.photo_max_size * H / W
            else:
                NewH = self.photo_max_size
                NewW = self.photo_max_size * W / H

            img = img.Scale(NewW,NewH)
            self.imageCtrl.SetBitmap(wx.BitmapFromImage(img))
            self.Refresh()
        ...