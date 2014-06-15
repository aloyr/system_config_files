#!/usr/bin/python
import requests, os
from pyquery import PyQuery

url = 'http://downloads.puppetlabs.com/mac/'
req = requests.get(url)

packages = {'puppet': '0', 'facter': '0', 'hiera': '0'}

print 'Checking puppet packages'
for item in PyQuery(url).items('a'):
  if (item.attr('href').find('rc') == -1) and (item.attr('href').find('hiera-puppet') == -1) and (item.attr('href').find('dmg') != -1):
    curPack = item.attr('href')[:-4].split('-')
    curVer  = curPack[1].split('.')
    preVer  = packages[curPack[0]].split('.')
    proc    = False
    for i in range(0,len(curVer)):
      if (len(preVer)-1 <  i) or (preVer[i] < curVer[i]):
        proc = True
        break
    if proc:
      packages[curPack[0]] = curPack[1]
      proc = False

foi = False
for dmg in packages.keys():
  arq = dmg + '-' + packages[dmg] + '.dmg'
  locArq = os.environ['HOME'] + '/Downloads/' + arq
  download = url + arq
  if os.path.isfile(locArq):
    print locArq + ' is already downloaded'
  else:
    foi = True
    print 'Downloading ' + arq + ' from ' + download
    file = open(locArq, 'wb')
    file.write(requests.get(download).content)
    file.close()
if foi:
  print 'Puppet dmg files downloaded to ' + os.environ['HOME'] + '/Downloads'
print "Done."