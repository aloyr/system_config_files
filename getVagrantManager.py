import requests, sys, os, shutil
from pyquery import PyQuery
from urlparse import urlparse
from subprocess import call

url = 'https://github.com/lanayotech/vagrant-manager/releases/latest'

request = requests.get(url)
links = PyQuery(request.text)

foi = False
for link in links('a'):
  if PyQuery(link).attr('href')[-3:] == 'dmg':
    foi = True
    break

if foi:
  remotefilename = PyQuery(link).attr('href')
  filename = remotefilename.split('/')[-1]
  locfile = os.environ['HOME'] + '/Downloads/' + filename
  if os.path.isfile(locfile):
    print locfile + ' is already downloaded'
  else:
    remotefilename = urlparse(url).scheme + '://' + urlparse(url).netloc + remotefilename if remotefilename[:4] != 'http' else remotefilename
    stream = requests.get(remotefilename, stream = True)
    with open(locfile, 'wb') as fd:
      print "getting " + filename
      count = 0
      for chunk in stream.iter_content(4096):
        count += 1
        if count%100 == 0:
          sys.stdout.write('.')
        fd.write(chunk)
      print 'done'
    print 'Vagrant Manager dmg file downloaded to ' + os.environ['HOME'] + '/Downloads'
    # exit(0)
    # # print 'Installing Vagrant Manager'
    # call(['hdiutil', 'mount', locfile])
    # call(['/usr/sbin/installer', '-pkg', '/Volumes/Vagrant/Vagrant.pkg', '-target', '/'])
    
    # call(['hdiutil', 'unmount', '/Volumes/Vagrant'])


