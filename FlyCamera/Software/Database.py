'''
Created on 4 Jul 2012

@author: az611
'''
import peewee
import ConfigParser
import socket

# Deferred initialisation
database = peewee.MySQLDatabase(None)
#database = peewee.MySQLDatabase('gglab', user='root')
# Address of this machine
local_address = None
#peewee.MySQLDatabase('gglab', user='root')
def ConnectToDatabase():
    global database
    global local_address

    try:
        # Load the parser
        parser = ConfigParser.SafeConfigParser()
        parser.read('config.ini')

        '''
        for section_name in parser.sections():
            print 'Section:', section_name
            print '  Options:', parser.options(section_name)
            for name, value in parser.items(section_name):
                print '  %s = %s' % (name, value)
        '''


        #parser.get('bug_tracker', 'url')
        host = parser.get('database', 'host')
        db = parser.get('database', 'db')
        user = parser.get('database', 'user')
        passwd = parser.get('database', 'passwd')

        #database = peewee.MySQLDatabase('gglab', user='root')
        #database = peewee.MySQLDatabase(database_name, user=database_user)
        #database.__init__(db, user=user, host=host, passwd=passwd)
        database.init(db, user=user, host=host, passwd=passwd)
        #database = peewee.MySQLDatabase('gglab', user='root')

        # Get the local address of this machine
        local_address = socket.gethostbyname(socket.gethostname())
    except Exception, e:
        print "ERROR in 'ConnectToDatabase': ", e


class BaseModel(peewee.Model):
    class Meta:
        database = database
# http://peewee.readthedocs.org/en/latest/peewee/fields.html
class Recording(BaseModel):
    # Experiment info
    date = peewee.DateTimeField()
    #author = peewee.ForeignKeyField(User, null=True)
    
    # Name of the video (not the name of the file)
    name = peewee.CharField(max_length=50)
    
    # Local address of the machine that hosts the videp
    host = peewee.CharField(max_length=255)
    # Video path on the OS
    path = peewee.CharField(max_length=255)
    # Length, in seconds
    length = peewee.IntegerField()
    # Codec
    codec = peewee.CharField(max_length=4, null=True)
    
    #chamber = peewee.ForeignKeyField(Chamber, related_name="chamber", null=True)
    #experiment = peewee.ForeignKeyField(Experiment, related_name="experiment", null=True)

    # Number of flies
    flies = peewee.IntegerField()
    # M, F, mix
    gender = peewee.IntegerField()
    # DoB
    date = peewee.DateTimeField(null=True)
    # Genotype
    genotype = peewee.CharField(max_length=255, null=True)
    
    # Comments
    comments = peewee.CharField(max_length=255)

    def __unicode__(self):
        return '%s, %s (%s sec)' % (self.name, self.date, self.length)
    
class User(BaseModel):
    firstName = peewee.CharField(max_length=50)
    lastName = peewee.CharField(max_length=50)

    def __unicode__(self):
        return '%s, %s' % (self.lastName, self.firstName)
    
    
class Chamber(BaseModel):
    name = peewee.CharField(max_length=50)

class Experiment(BaseModel):
    # Comments
    name = peewee.CharField(max_length=50)
    # Comments
    comments = peewee.CharField(max_length=255)
    

def SaveRecordingDataOnDB(**args):
    try:
        database.connect()
        
        #print args
        #query = Recording.insert(host=local_address, **args)
        query = Recording.insert(host=local_address, **args)
        #query = peewee.InsertQuery(Recording, **args)
        #print "\tQUERY: ", query.sql()
        return query.execute()

        #database.disconnect()
    except Exception, e:
        print "ERROR in SaveRecordingDataOnDB!: ", e
        return None
        #raise e
    
def UpdateRecordingDataOnDB(idR, **args):
    try:
        database.connect()
        #print args
        #query = Recording.update(**args).where(id=args['id'])
        query = Recording.update(**args).where(id=idR)
        #query = peewee.InsertQuery(Recording, **args)
        #print "\tQUERY: ", query.sql()
        query.execute()
        return True
        #database.disconnect()
    except Exception, e:
        print "ERROR in UpdateRecordingDataOnDB!: ", e
        return False
        #raise e
        
def GetAllRecordings():
    try:
        database.connect()
        #print args
        #query = Recording.update(**args).where(id=args['id'])
        query = Recording.select()
        #query = peewee.InsertQuery(Recording, **args)
        #print "\tQUERY: ", query.sql()
        result = query.execute()
        return result
        #database.disconnect()
    except Exception, e:
        print "ERROR in GetAllRecordings!: ", e
        return None
    
'''
if __name__ == "__main__":
    database.connect()
    recordings = Recording.select().where(genotype="a")
    for recording in recordings:
        print recording.genotype
    print "END"
'''