#!/usr/bin/python
import os, requests, re
from pyquery import PyQuery

url = 'http://www.macports.org/install.php'

print "Checking macports package"
req = requests.get(url)
for link in re.findall(r'a href="[^"]*', req.text):
  if link.find('Sierra') != -1:
    break

link = link[8:]
arq = link[link.find('MacPorts-'):]
download = os.environ['HOME'] + '/Downloads/' + arq

foi = False
if os.path.isfile(download):
  print arq + ' is already downloaded'
else:
  foi = True
  print 'Downloading ' + arq + ' from ' + download
  file = open(download, 'wb')
  file.write(requests.get(link).content)
  file.close()
if foi:
  print 'MacPorts package file downloaded to ' + os.environ['HOME'] + '/Downloads'
