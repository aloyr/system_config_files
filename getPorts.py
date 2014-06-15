#!/usr/bin/python
import os, requests, re
from pyquery import PyQuery

url = 'http://www.macports.org/install.php'

req = requests.get(url)
for link in re.findall(r'a href="[^"]*', req.text):
  if link.find('Mavericks') != -1:
    break

link = link[8:-1]
arq = link[link.find('MacPorts-'):]
download = os.enrivon['HOME'] + '/Downloads/' + arq

if os.isfile(download):
  print arq + ' is already downloaded'
else:
  foi = True
  print 'Downloading ' + arq + ' from ' + download
  file = open(download, 'wb')
  file.write(requests.get(link).content)
  file.close()
if foi:
  print 'MacPorts dmg files downloaded to ' + os.environ['HOME'] + '/Downloads'
