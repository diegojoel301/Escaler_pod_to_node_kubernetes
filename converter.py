#!/usr/bin/python3

import sys
import yaml
import json

name_file_yaml = sys.argv[1]

with open(name_file_yaml, 'r') as file:
    configuration = yaml.safe_load(file)
with open('ptn.json', 'w') as json_file:
    json.dump(configuration, json_file)
output = json.dumps(json.load(open('ptn.json')), indent = 2)
print(output)
