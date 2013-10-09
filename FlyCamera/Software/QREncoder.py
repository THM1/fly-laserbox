'''
Created on 3 Jul 2012

@author: az611
'''
import zbar
import qrcode

# http://python.dzone.com/articles/creating-qr-codes-python
def encodeFromTest (text, path, format='PNG') :
    qr = qrcode.QRCode(version=1, box_size=10, border=4)
    qr.add_data(text)
    qr.make(fit=True)
    x = qr.make_image()
    
    img_file = open(path, 'wb')
    x.save(img_file, format)
    img_file.close()
    #self.showQRCode(qr_file)

    '''
    qr_file = os.path.join(self.defaultLocation, self.qrPhotoTxt.GetValue() + ".jpg")
    img_file = open(qr_file, 'wb')
    x.save(img_file, 'JPEG')
    img_file.close()
    self.showQRCode(qr_file)
    '''