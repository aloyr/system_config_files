import urllib
def urlimport(url):
  filepath = urllib.urlretrieve(url)[0]
  with open(filepath) as f:
    exec f in globals();

urlimport('https://raw.githubusercontent.com/aloyr/system_config_files/master/lib/autoinstall.py')

#autoinstall.download('http://www.trankynam.com/atext/')
download('http://www.amazon.com/gp/feature.html?docId=1000464931')
