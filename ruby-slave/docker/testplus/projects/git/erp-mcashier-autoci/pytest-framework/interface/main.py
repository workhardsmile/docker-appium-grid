#!/usr/bin/python
#-*- coding:utf-8 -*-
import unittest
import HTMLTestRunner,time
from interface.data.redisdata import *

listaa = './app'


def suit():
    loader = unittest.TestLoader()
    # suite = loader.discover(listaa,pattern='user_*.py')
    suite = loader.discover(listaa,pattern='*.py')
    return suite


# print suit()


def reset():
    test_redis.expire('sms:register:success_count:13540108163',1)
    test_redis.expire('sms:register:error_count:13540108163',1)


    test_redis.expire('sms:register:success_count:18980709020',1)
    test_redis.expire('sms:forget_password:success_count:18980709020',1)
    test_redis.expire('sms:update_password:success_count:18980709020',1)
    test_redis.expire('sms:register:error_count:18980709020',1)
    test_redis.expire('sms:forget_password:error_count:18980709020',1)
    test_redis.expire('sms:update_password:error_count:18980709020',1)

reset()

now = time.strftime("%Y-%m-%d-%H_%M_%S",time.localtime(time.time()))
# print now

filename = './report/'+ now +'_result.html'
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