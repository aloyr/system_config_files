import requests
from pyquery import PyQuery

url = 'http://downloads.puppetlabs.com/mac/'
req = requests.get(url)

packages = {'puppet': '0', 'facter': '0', 'hiera': '0'}

for item in PyQuery(url).items('a'):
  if (item.attr('href').find('rc') == -1) and (item.attr('href').find('dmg') != -1):
    print item.attr('href')
    curPack = item.attr('href')[:-4].split('-')
    curVer  = curPack[1].split('.')
    preVer  = packages[curPack[0]].split('.')
    proc    = False
    for i in range(0,len(curVer)):
      print 'curver ' + str(curVer)
      print 'index ' + str(i) + ' comparing ' + curPack[1] + ' with ' + packages[curPack[0]]
      if (len(preVer)-1 <  i) or (preVer[i] < curVer[i]):
        print "got it"
        proc = True
        break
    if proc:
      packages[curPack[0]] = curPack[1]
      print 'setting packages'
      print packages
      proc = False

for dmg in packages.keys():
  arq = dmg + '-' + packages[dmg] + '.dmg'
  download = url + arq
  print 'Downloading ' + arq + ' from ' + download
  file = open(arq, 'wb')
  file.write(requests.get(download).content)
  file.close()

print "done."