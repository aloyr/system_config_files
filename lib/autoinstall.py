import requests, os, re, subprocess, sys, traceback
from distutils import dir_util
from pyquery import PyQuery

def download(url = None, downloadFolder = os.environ['HOME'] + '/Downloads/'):
	if url == None:
		return None
	installApps(downloadFiles(getURLs(url), downloadFolder))

def getURLs(url):
	print 'url is ' + url
	try:
		print 'using ' + url
		result = []
		request = requests.get(url)
		links = PyQuery(request.text)
		for link in links('a'):
			href = PyQuery(link).attr('href')
			if href != None and len(href) > 3 and href[-3:] in ['pkg', 'dmg', 'zip']:
				if href[0:4] != 'http':
					href = url + href
				result.append(href)
				print 'found ' + href
				try:
					if result[-1].find('aText.dmg'):
						version = links('#version')[0].text.replace('\n','').replace('\t','')
						result[-1] = result[-1][:-4] + '-' + version + result[-1][-4:]
				except:
					pass
				return	result
				break
		sys.exit(0)
	except:
		print "Unexpected error:", sys.exc_info()
		print traceback.print_exc()

		return None
		# raise

def downloadFiles(urls, downloadFolder = os.environ['HOME'] + '/Downloads/'):
	if urls == None:
		return None
	result = []
	for remotefilename in urls:
		filename = re.sub(r'.*=','',remotefilename.split('/')[-1])
		locfile = downloadFolder + filename
		if remotefilename.find('aText') and remotefilename.find('-'):
			remotefilename = remotefilename[0:remotefilename.find('-')] + remotefilename[-4:]
		if os.path.isfile(locfile):
			print locfile + ' is already downloaded'
		else:
			result.append(locfile)
			stream = requests.get(remotefilename, stream = True)
			with open(locfile, 'wb') as fd:
				print "getting " + filename
				count = 0
				for chunk in stream.iter_content(4096):
					count += 1
					if count%100 == 0:
						sys.stdout.write('.')
					fd.write(chunk)
			print filename + ' file downloaded to ' + downloadFolder
	return result

def installApps(files):
	if files == None:
		return None
	for locfile in files:
		print 'Installing ' + locfile.split('/')[-1]
		if locfile[-3:] == 'dmg':
			dmg = subprocess.Popen(['hdiutil','mount',locfile], stdout = subprocess.PIPE)
			vol = dmg.communicate()[0].split('\t')[-1].split('\n')[0]
			# TODO - install dmg file
			subprocess.Popen(['hdiutil','unmount',vol]).wait()
		if locfile[-3:] == 'pkg':
			subprocess.Popen(['/usr/sbin/installer', '-pkg', locfile, '-target', '/']).wait()
		print 'done'

# if __name__ == "__main__":
#    download(sys.argv[1])
