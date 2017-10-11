#!/usr/bin/python
#-*- coding:utf-8 -*-
import unittest
import HTMLTestRunner,time
from interface.data.redisdata import *

listaa = './admin'


def suit():
    loader = unittest.TestLoader()
    suite = loader.discover(listaa,pattern='*.py')
    return suite




now = time.strftime("%Y-%m-%d-%H_%M_%S",time.localtime(time.time()))

filename = './report/'+ now +'_admin_result.html'
fp = file(filename,'wb')

runner = HTMLTestRunner.HTMLTestRunner(
    stream=fp,
    title=u'ironhide接口测试报告',
    description = u'用例执行情况：'
)
runner.run(suit())

# if __name__=='__main__':
    # unittest.main(defaultTest=suit(),verbosity=2)
    # runner.run(suit())