'''
Created on Jul 10, 2012

@author: Alan Zucconi
'''
import wx
import wx.grid

class InfoTable(wx.grid.Grid):
    def __init__(self, parent, data, rowLabels=None, colLabels=None):
        wx.grid.Grid.__init__(self, parent, -1)
        tableBase = InfoTableBase(data, rowLabels, colLabels)
        self.SetTable(tableBase)
        
        if rowLabels is None:
            self.SetRowLabelSize(1)
        if colLabels is None:
            self.SetColLabelSize(1)
    
class InfoTableBase(wx.grid.PyGridTableBase):
    def __init__(self, data, rowLabels=None, colLabels=None):
        wx.grid.PyGridTableBase.__init__(self)
        self.data = data
        self.rowLabels = rowLabels
        self.colLabels = colLabels
        
        
    def GetNumberRows(self):
        return len(self.data)

    def GetNumberCols(self):
        return len(self.data[0])

    def GetColLabelValue(self, col):
        if self.colLabels:
            return self.colLabels[col]
        
    def GetRowLabelValue(self, row):
        if self.rowLabels:
            return self.rowLabels[row]
        
    def IsEmptyCell(self, row, col):
        return False

    def GetValue(self, row, col):
        return self.data[row][col]

    def SetValue(self, row, col, value):
        self.data[row][col] = value
        #pass         

'''
data = (("A", "B"), 
        ("C", "D"), 
        ("E", "F"), 
        ("G", "G"),
        ("F", "F"), 
        ("Q", "Q"))
            
colLabels = ("Last", "First")
rowLabels = ("1", "2", "3", "4", "5", "6", "7", "8", "9")
'''