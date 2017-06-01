import json
import urllib
import urllib2
import re
import sys
from distutils.version import StrictVersion

def sort_version(x, y):
    x_ = x.split('-')[0]
    y_ = y.split('-')[0]
    if StrictVersion(x_) > StrictVersion(y_):
        return -1
    if StrictVersion(x_) == StrictVersion(y_):
        return 0
    if StrictVersion(x_) < StrictVersion(y_):
        return 1

def get_tomcat_versions():
    try:
        response = urllib2.urlopen("https://api.daocloud.io/hub/v2/hub/repos/47f127d0-8f1d-4f91-9647-739cf3146a04/tags?page_size=-1")
        tomcat_versions = json.load(response).get('results')

        tomcat_version_names = []
        tomcat_8_version_names = []
        tomcat_7_version_names = []
        tomcat_6_version_names = []

        for v in tomcat_versions:
            version_name = v['name']
            if re.match('^8\.[5-9]\.\d+-jre8$', version_name):
                tomcat_version_names.append(version_name)
            if re.match('^8\.0\.\d+-jre8$', version_name):
                tomcat_8_version_names.append(version_name)
            if re.match('^7\.\d+\.\d+-jre8$', version_name):
                tomcat_7_version_names.append(version_name)
            if re.match('^6\.\d+\.\d+-jre8$', version_name):
                tomcat_6_version_names.append(version_name)

        collect_versions = sorted(tomcat_version_names, cmp=sort_version)[0:3] + sorted(tomcat_8_version_names, cmp=sort_version)[0:3] + sorted(tomcat_7_version_names, cmp=sort_version)[0:3] + sorted(tomcat_6_version_names, cmp=sort_version)[0:3]
        print ' '.join(collect_versions)
    except Exception as e:
        print "Error: {}".format(e)
        sys.exit(1)


def main():
    get_tomcat_versions()

if __name__ == '__main__':
    main()
