'''
Created on 12 Jul 2012

@author: az611
'''
import wx
from CameraPanel import *


ADMIN = 0
PROCESSES = 1
TOOLS = 2

class LateralPanel (wx.Panel):
    
    __sizerAdmin = None
    __sizerProcesses = None
    __sizerTools = None

    __sections = None



    def __init__ (self, parent):
        wx.Panel.__init__(self, parent, wx.ID_ANY)

        sb_0 = wx.StaticBox(self, label="Admin")
        self.__sizerAdmin = wx.StaticBoxSizer(sb_0, wx.VERTICAL)

        sb_1 = wx.StaticBox(self, label="Processes")
        self.__sizerProcesses = wx.StaticBoxSizer(sb_1, wx.VERTICAL)

        sb_2 = wx.StaticBox(self, label="Tools")
        self.__sizerTools = wx.StaticBoxSizer(sb_2, wx.VERTICAL)


        #self.__sizerProcesses.Add(  wx.StaticText(self, -1, "Processes"), 
        #    flag=wx.LEFT|wx.TOP, border=5)
        #self.__sizerProcesses.Add(wx.Button(self ,label="Camera 1"), proportion=0,flag=wx.ALL, border=2)
        #self.__sizerProcesses.Add(wx.Button(self ,label="Camera 2"),proportion=0,flag=wx.ALL,  border=2)
        #self.__sizerProcesses.Add(wx.Button(self ,label="Camera 3"),proportion=0,flag=wx.ALL,  border=2)
        #self.__sizerProcesses.Add(wx.Button(self ,label="Camera 4"), proportion=0,  flag=wx.ALL, border=2)

        sizer_0 = wx.BoxSizer(wx.VERTICAL)
        sizer_0.Add(self.__sizerAdmin, flag=wx.EXPAND|wx.TOP|wx.LEFT|wx.RIGHT , border=10)
        sizer_0.Add(self.__sizerProcesses, flag=wx.EXPAND|wx.TOP|wx.LEFT|wx.RIGHT , border=10)
        sizer_0.Add(self.__sizerTools, flag=wx.EXPAND|wx.TOP|wx.LEFT|wx.RIGHT , border=10)
        
        self.SetSizer(sizer_0)
        sizer_0.Fit(self)
        self.Layout()


        self.__sections = [self.__sizerAdmin, self.__sizerProcesses, self.__sizerTools]

    def AddButton (self, section, component, label, handler):


        button = wx.Button(self ,label=label)
        self.Bind(wx.EVT_BUTTON,
            lambda event: handler(component),
            button)

        sizer = self.__sections[section]
        sizer.Add(button, proportion=0, flag=wx.ALL, border=2)
        self.Layout();