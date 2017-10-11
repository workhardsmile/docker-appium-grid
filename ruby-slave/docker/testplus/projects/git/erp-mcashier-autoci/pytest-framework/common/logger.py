#!/usr/bin/python
#-*- coding:utf-8 -*-
import logging
import os
from interface.testmain import *

# filename='/Users/Anry/ironhide-test/output/test_results/'+get_filename()
filename = os.path.dirname(__file__) + '/../output/test_results/' + get_filename()
# print filename
logging.basicConfig(level=logging.DEBUG,
                format='%(asctime)s %(filename)s[line:%(lineno)d] %(levelname)s %(message)s',
                datefmt='%Y-%m-%d %H:%M:%S',
                filename= filename,
                # filename= log_file2,
                filemode='w')

#定义一个StreamHandler，将INFO级别或更高的日志信息打印到标准错误，并将其添加到当前的日志处理对象#
console = logging.StreamHandler()
console.setLevel(logging.INFO)
# formatter = logging.Formatter('%(name)-12s: %(levelname)-8s %(message)s')
formatter = logging.Formatter('%(name)s: %(levelname)s %(message)s')
console.setFormatter(formatter)
logging.getLogger('').addHandler(console)
