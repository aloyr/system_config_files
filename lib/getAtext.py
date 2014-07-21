import urllib
def urlimport(x):
  exec urllib.urlopen(x) in globals()

urlimport('https://raw.githubusercontent.com/aloyr/system_config_files/master/lib/autoinstall.py')

autoinstall.download('http://www.trankynam.com/atext/')
