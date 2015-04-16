#!/usr/bin/python
# -*- mode: python; coding: utf-8 -*-

import jinja2
import os
import sys
import tempfile

sys.stderr.write('=' * 75 + '\n')

keys = os.environ.keys()
keys.sort()
for key in keys:
    sys.stderr.write('{}: {}\n'.format(key, os.environ[key]))

sys.stderr.write('=' * 75 + '\n')

env = jinja2.Environment(loader = jinja2.FileSystemLoader(['/etc/logstash']),
                         keep_trailing_newline = True)
config_template = env.get_template('logstash.conf')
config = config_template.render(**os.environ).encode('utf-8')

sys.stderr.write('=' * 75 + '\n')

sys.stderr.write(config)

sys.stderr.write('=' * 75 + '\n')

config_file, config_filename = tempfile.mkstemp()
config_file.write(config)
config_file.close()

sys.stderr.write('=' * 75 + '\n')

os.execl('/logstash/bin/logstash', '/logstash/bin/logstash', '--config', config_filename)
