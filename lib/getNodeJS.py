#!/usr/bin/python
import requests, sys, os
from pyquery import PyQuery
import subprocess

url = 'http://nodejs.org/download/'

request = requests.get(url)
links = PyQuery(request.text)

foi = False
for link in links('a'):
  if PyQuery(link).attr('href')[-3:] in ['pkg', 'dmg']:
    foi = True
    break

if foi:
  remotefilename = PyQuery(link).attr('href')
  filename = remotefilename.split('/')[-1]
  locfile = os.environ['HOME'] + '/Downloads/' + filename
  if os.path.isfile(locfile):
    print locfile + ' is already downloaded'
  else:
    stream = requests.get(remotefilename, stream = True)
    with open(locfile, 'wb') as fd:
      print "getting " + filename
      count = 0
      for chunk in stream.iter_content(4096):
        count += 1
        if count%100 == 0:
          sys.stdout.write('.')
        fd.write(chunk)
    print 'NodeJS file downloaded to ' + os.environ['HOME'] + '/Downloads'
    print 'Installing NodeJS'
    if locfile[-3:] == 'dmg':
      dmg = subprocessPopen(['hdiutil','mount',locfile], stdout = subprocess.PIPE)
      vol = dmg.communicate()[0].split('\t')[-1].split('\n')[0]
      # TODO - install dmg file
      subprocessPopen(['hdiutil','unmount',vol]).wait()
    if locfile[-3:] == 'pkg':
      subprocess.Popen(['/usr/sbin/installer', '-pkg', locfile, '-target', '/']).wait()
    print 'done'
    # call(['hdiutil', 'mount', locfile])
    # call(['/usr/sbin/installer', '-pkg', '/Volumes/Vagrant/Vagrant.pkg', '-target', '/'])
    # call(['hdiutil', 'unmount', '/Volumes/Vagrant'])
    # call(['vagrant', 'plugin', 'install', 'vagrant-cachier', 'vagrant-hostsupdater', 'vagrant-triggers'])
    # call(['chmod', '-R', '777', '~/.vagrant.d/cache'])
