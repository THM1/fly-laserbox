'''
Created on Jul 10, 2012

@author: Alan Zucconi
'''
import wx
from wx.lib.mixins.listctrl import TextEditMixin

class InfoList(wx.ListCtrl, TextEditMixin):
    __rowLabels = None
    __editHandler = None
    def __init__(self, parent, data, rowLabels=None, colLabels=None, editHandler = None):
        #wx.ListCtrl.__init__(self, parent, -1,style=wx.LC_REPORT|wx.SUNKEN_BORDER)
        wx.ListCtrl.__init__(self, parent, -1,style=wx.LC_REPORT|wx.LC_VRULES|wx.LC_HRULES)
        TextEditMixin.__init__(self) 
        #tableBase = InfoTableBase(data, rowLabels, colLabels)
        #self.SetTable(tableBase)
        # http://docs.wxwidgets.org/trunk/classwx_list_event.html
        
        self.__editHandler = editHandler
        self.Bind(wx.EVT_LIST_END_LABEL_EDIT, self.OnEndLabelEdit, self)
        
        i = 0
        for col in colLabels:
            self.InsertColumn(i,str(col))
            i=i+1
            
        i = 0
        for row in rowLabels:
            self.InsertStringItem(i, str(row))
            if data[i] is not None:
                string = str(data[i])
            else:
                string = ""
            self.SetStringItem(i, 1, string)
            i = i+1
        #self.GetAllData();
        
        self.__rowLabels = rowLabels
        '''
        if rowLabels is None:
            self.SetRowLabelSize(1)
        if colLabels is None:
            self.SetColLabelSize(1)
        '''
         
        self.Show(True)
    
    def OnEndLabelEdit (self, event):
        index = event.GetIndex()
        propertyName = self.GetItem(index, 0).GetText()
        propertyValue = event.GetLabel()
        
        #print propertyName, "\t", propertyValue
        
        if self.__editHandler is not None:
            self.__editHandler(propertyName, propertyValue)
    
    # http://docs.wxwidgets.org/2.8/wx_wxlistctrl.html#wxlistctrlgetitem
    def GetAllData (self):
        data = {}
        
        for i in range(self.GetItemCount()):
            data[self.GetItem(i,0).GetText()] = self.GetItem(i,1).GetText()
        
        return data
    
    def SetNewData (self, data):
        for name in data:
            try:
                index = self.__rowLabels.index(str(name))
            except ValueError, e:
                #print "UNKNOWN VALUE (", str(name), "): ", e
                continue
                # New elements are not added automatically
            
            
            # Won't overwrite previous data
            # that were not setted
            datum = data[name]
            if (    datum is None    or
                    datum == ''     ):
                continue
            
            self.SetStringItem(index, 1, str(datum))
    
    def ClearAllData (self):
        #self.DeleteAllItems()
        for i in range(self.GetItemCount()):
            self.SetStringItem(i, 1, '')