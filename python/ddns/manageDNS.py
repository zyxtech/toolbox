#!/usr/bin/python
# -*- coding: UTF-8 -*-
import json
import ConfigParser
import urllib,urllib2
import time

# no need to change config.cfg manually,it will be changed by this python script
# load data from config.cfg
config = ConfigParser.ConfigParser()
config.read('config.cfg')
print '\n\n'
print 'currentTime is :', time.asctime( time.localtime(time.time()) )
print '-----------------loading config.cfg-------------------'
print 'currIP is:', config.get('config', 'currIP')
print 'currDNSIP is:', config.get('config', 'currDNSIP')
print 'trytoChangeTimes is:', config.get('config', 'trytoChangeTimes')

# check current real IP
response = urllib2.urlopen('http://zyxtech.org/ip.php')
realIP = response.read()
print 'realIP is:', realIP

# load data from dns.la
currIP = '';
dnsRecordId = '';
domainId = '';
data = '';
if (realIP != config.get('config','currIP') or config.get('config','currIP') != config.get('config','currDNSIP') ):
  # change yourapiid,yourapipass,yourdomain to your config ,yourdomain like zyxtech.org
  dnsdata = urllib2.urlopen("https://api.dns.la/api/record.ashx?cmd=list&apiid=yourapiid&apipass=yourapipass&rtype=json&domain=yourdomain&domainid")
  data = json.loads(dnsdata.read())
  for i in range(0,len(data['datas'])):
    #change yoursubdomain here, change to aa if your domain is like aa.zyxtech.org
    if data['datas'][i]['host'] == 'yoursubdomain':
      currIP = data['datas'][i]['record_data'];
      dnsRecordId = data['datas'][i]['recordid'];
      domainId = data['datas'][i]['domainid']
      break;

# compare config file and currentIP
if (realIP != config.get('config','currIP') or config.get('config','currIP') != config.get('config','currDNSIP') ):
  #change yourapiid,yourapipass,yourhost to your config
  urlData = urllib.urlencode({'cmd':'edit','apiid':'yourapiid','apipass':'yourapipass','domainid':domainId,'domain':'','recordid':dnsRecordId,'host':'yourhost','recordtype':'A','recordline':'Def','recorddata':realIP,'mxpriority':'','ttl':'600'})
 # response = urllib2.urlopen("https://api.dns.la/api/record.ashx?cmd=edit&apiid=yourapiid&apipass=yourapipass&domainid=1878758&domain=&recordid=4655549&host=yourhost&recordtype=A&recordline=Def&recorddata=",realIP,"&mxpriority=&ttl=600" )
  response = urllib2.urlopen('https://api.dns.la/api/record.ashx?'+urlData)
  #print "response is :",response.read()
  responseData = json.loads(response.read())
  if responseData['status']['code'] == 300 :
    config.set('config','currDNSIP',realIP)
    config.set('config','trytoChangeTimes',1)
    print 'change record success'
  else:
    print 'change record false'
    config.set('config','trytoChangeTimes',config.get('config', 'trytoChangeTimes')+1)
  config.set('config','currIP',realIP)
  with open('config.cfg', 'wb') as configfile:
    config.write(configfile)
else:
  print 'nothing need to do'
