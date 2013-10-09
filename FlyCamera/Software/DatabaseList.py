'''
Created on 12 Jul 2012

@author: az611
'''
import wx
from wx.lib.mixins.listctrl import TextEditMixin
import peewee

from Database import *

class DatabaseList (wx.ListCtrl, TextEditMixin):
    # The peewee class from which data will be loaded
    #__databaseClass = None
    #def __init__ (self, parent, databaseClass):
    __colLabels = None
    def __init__ (self, parent, colLabels=['name','length','date', 'flies','gender','genotype','comments', 'host','path']):
        #wx.Panel.__init__(self, parent, wx.ID_ANY)
        wx.ListCtrl.__init__(self, parent, -1,style=wx.LC_REPORT|wx.LC_VRULES|wx.LC_HRULES)
        TextEditMixin.__init__(self) 
        #tableBase = InfoTableBase(data, rowLabels, colLabels)
        #self.SetTable(tableBase)
        # http://docs.wxwidgets.org/trunk/classwx_list_event.html
        
        #self.__editHandler = editHandler
        #self.Bind(wx.EVT_LIST_END_LABEL_EDIT, self.OnEndLabelEdit, self)
        
        self.__colLabels = colLabels
        i = 0
        for col in self.__colLabels:
            self.InsertColumn(i, str(col))
            i = i+1
        
        
        
    def UpdateListFromDBTable(self, table):
        self.DeleteAllItems()
        
        if table is None:
            return

        i = 0
        for row in table:
            self.InsertStringItem(i, str(row.name))
            
            self.SetStringItem(i,1, str(row.length))
            self.SetStringItem(i,2, str(row.date))
            self.SetStringItem(i,3, str(row.flies))
            self.SetStringItem(i,4, str(row.gender))
            self.SetStringItem(i,5, str(row.genotype))
            #self.SetStringItem(i,5, str(row.dob))
            self.SetStringItem(i,6, str(row.comments))
            self.SetStringItem(i,7, str(row.host))
            self.SetStringItem(i,8, str(row.path))
            i = i+1 
        #['name','lenght','flies','gender','genotype','dob','comments','path']
        #for col in self.__colLabels:
            
        
class DatabaseListPanel (wx.Panel):
    __list = None
    def __init__ (self, parent):
        wx.Panel.__init__(self, parent, wx.ID_ANY)
        
        
        self.__list = DatabaseList(self)
        self.__refreshButton = wx.Button(self, -1, "Refresh")
        #self.__refreshButton = wx.Button(self, -1, "Refresh")
        
        self.Bind(wx.EVT_BUTTON, self.OnRefreshButton, self.__refreshButton)
        
        
        sizer_controls = wx.BoxSizer(wx.HORIZONTAL) 
        sizer_controls.Add((20, 20), 10, wx.EXPAND, 0)
        sizer_controls.Add(self.__refreshButton, 0, wx.EXPAND, 0)
        sizer_controls.Add((5,20), 0,0,0)
        
        
        
        # Main sizer
        sizer_1 = wx.BoxSizer(wx.VERTICAL)
        sizer_1.Add(self.__list, 10, wx.EXPAND, 0)
        sizer_1.Add((5,5), 0,0,0)
        sizer_1.Add(sizer_controls, 0, wx.EXPAND, 0)
        sizer_1.Add((20,5), 0,0,0)
        
        # Fit
        self.SetSizer(sizer_1)
        sizer_1.Fit(self)
        self.Layout()
        
    def UpdateListFromDBTable(self, table):
        self.__list.UpdateListFromDBTable(table)
        
    def OnRefreshButton(self, event):
        table = GetAllRecordings()
        self.UpdateListFromDBTable(table)