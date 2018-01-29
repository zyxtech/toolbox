from ruamel.yaml import YAML, sys
import os

hostnames = open("config.yaml", "r")
yaml_hostnames = YAML()
hostnames_yaml = yaml_hostnames.load(hostnames)
hostnameandips = ""
for node in hostnames_yaml['config']['nodes']:
    if node['hostname'] is False:
        hostnameandips += node['ip'] + ' ' + node['ip'].replace(".", "_") + '\n'
    else:
        hostnameandips += node['ip'] + ' ' + node['hostname'] + '\n'
for i in range(len(hostnames_yaml['config']['salt-config']['master'])):
    hostnameandips += hostnames_yaml['config']['salt-config']['master'][i] + ' '
    hostnameandips += hostnames_yaml['config']['salt-config']['master_host'][i] + '\n'

for node in hostnames_yaml['config']['nodes']:

    sshcmd = ('sshpass -p \"' + str(node['ssh']['pass']) + '\" ssh -p'
              + str(node['ssh']['port']) + ' '
              + node['ssh']['user'] + '@'
              + node['ip'] + ' ')
    if node['hostname'] is False:
        hostname = str(node['ip']).replace(".", "-")
    else:
        hostname = str(node['hostname'])
    os.popen(sshcmd + "\'cat >> /etc/hosts <<EOF\n" + hostnameandips + "EOF\n\'")

    if node['hostname'] is False:
        os.popen(sshcmd + "\'hostnamectl set-hostname %s --static \'" % hostname)
    else:
        os.popen(sshcmd + "\'hostnamectl set-hostname %s --static \'" % hostname)

    os.popen(sshcmd + "\' yum -y install %s \'" % saltrepo)
    os.popen(sshcmd + "\' yum remove -y salt salt-minion \'")
    os.popen(sshcmd + "\' rm -fR /var/log/salt* /var/cache/salt* /var/run/salt* /etc/salt* \'")

    os.popen(sshcmd + "\' yum clean all && yum -y install salt salt-minion ;yum clean all && " +
             "yum -y install salt salt-minion \'")
    os.popen(sshcmd + "\' curl http://%s/minion -o /etc/salt/minion\'" % str(
        hostnames_yaml['config']['salt-config']['master'][i]))

    print (sshcmd + "\'sed -i \"s/^#\?id:.*$/id: %s/\" /etc/salt/minion;systemctl restart salt-minion ;"
                      "systemctl restart salt-minion \'" % hostname)
    os.popen(sshcmd + "\'sed -i \"s/^#\?id:.*$/id: %s/\" /etc/salt/minion;systemctl restart salt-minion ;"
                      "systemctl restart salt-minion \'" % hostname)

