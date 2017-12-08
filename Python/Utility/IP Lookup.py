import re
import json
from urllib2 import urlopen
import csv


with open('C:\Users\jamesd26\Desktop\Book1.csv', 'rb') as f:
    reader = csv.reader(f)
    your_list = list(reader)
item = 0
for x in your_list:
    if item == 0:
        item = 1
        pass
    else:
        ip = x[0].replace("'", "")
        url = r'http://ipinfo.io/' + ip + r'/json'
        
        response = urlopen(url)
        data = json.load(response)
        LOC = data['loc']
        print x[0], x[1], LOC
        x.append(LOC)
count = 0

for y in your_list:
    if count == 0:
        count = 1
        pass
    else:
        print y
