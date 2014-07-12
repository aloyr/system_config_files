#!/usr/bin/python
import requests, os, sys
from pyquery import PyQuery
import subprocess
from distutils import dir_util


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
  filename = dmg + '-' + packages[dmg] + '.dmg'
  locfile = os.environ['HOME'] + '/Downloads/' + filename
  remotefilename = url + filename
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
    print filename + ' file downloaded to ' + os.environ['HOME'] + '/Downloads'
    print 'Installing ' + filename 
    if locfile[-3:] == 'dmg':
      dmg = subprocess.Popen(['hdiutil','mount',locfile], stdout = subprocess.PIPE)
      vol = dmg.communicate()[0].split('\t')[-1].split('\n')[0]
      # TODO - install dmg file
      for item in os.listdir(vol):
        if item[-3:] == 'app':
          dir_util.copy_tree(vol + '/' + item, '/Applications/' + item)
          break
        elif item[-3:] == 'pkg':
          subprocess.Popen(['/usr/sbin/installer','-pkg',vol + '/' + item,'-target','/']).wait()
          break
      subprocess.Popen(['hdiutil','unmount',vol]).wait()
    if locfile[-3:] == 'pkg':
      subprocess.Popen(['/usr/sbin/installer', '-pkg', locfile, '-target', '/']).wait()
    print 'done'
 
