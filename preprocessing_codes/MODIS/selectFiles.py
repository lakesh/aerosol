#! /usr/bin/python

import os
import shutil

path='/home/lakesh/Desktop'

#leftLongitude=78.0451
#rightLongitude=70.55000
#topLatitude=44.233889
#bottomLatitude=40.035833

src_dir = path + '/' + '2007/'
dest_dir = path + '/' + 'selected/'

listing=os.listdir(src_dir)
for file in listing:
    #print "file is " + file
    data=file.split('.')
    latitude=data[4]
    longitude=data[3]
    firstCharLatitude=latitude[0]
    firstCharLongitude=longitude[0]
    latitude=latitude[1:]
    longitude=longitude[1:]
    latitude=float(latitude)
    longitude=float(longitude)

    #If the data lies in the northwestern region of the earth(where USA lies) then copy that file
    if firstCharLatitude=='N' and firstCharLongitude=='W':
        print file
	shutil.copyfile(src_dir + str(file), dest_dir + str(file))
    


