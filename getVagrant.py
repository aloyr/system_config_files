import requests, sys, os
from pyquery import PyQuery
from subprocess import call

url = 'http://www.vagrantup.com/downloads.html'

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
		print 'Vagrant dmg file downloaded to ' + os.environ['HOME'] + '/Downloads'
		print 'Installing Vagrant'
		call(['hdiutil', 'mount', locfile])
		call(['/usr/sbin/installer', '-pkg', '/Volumes/Vagrant/Vagrant.pkg', '-target', '/'])
		call(['hdiutil', 'unmount', '/Volumes/Vagrant'])
		call(['vagrant', 'plugin', 'install', 'vagrant-cachier', 'vagrant-hostsupdater', 'vagrant-triggers'])


