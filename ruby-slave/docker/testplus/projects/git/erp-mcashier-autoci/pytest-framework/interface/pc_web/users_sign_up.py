#!/usr/bin/python
# -*- coding:utf-8 -*-
import unittest,time
from interface import myunittest
from interface.testbasic import *
from interface.data.redisdata import *
from interface.data.mysqldata import *


def test(params,headers=None):
    r = ironhide().interfacetest('/api/website/users/sign_up', 'POST', params,headers,type='pc_web')
    return r

class test_users_sign_up(myunittest.TestCase):
    # 注册
    def test_1(self):
        u"""注册账号"""
        self.case_id = 'test_1'
        code = getsms_code(1, self.mobile_unregister)
        time.sleep(2)
        username = 'test' + str(int(time.time()))[5:]
        params = {'user_name': username,
                  'password': '123456',
                  'mobile': self.mobile_unregister,
                  'code': code}
        r = test(params)
        if getcode(r) == 1:
            resetuser(username)
        print r.content
        self.assertEqual(getcode(r), 1)

    def test_2(self):
        u"""注册账号：验证码错误"""
        self.case_id = 'test_2'
        params = {'user_name': 'tester-Anry',
                  'password': '123456',
                  'mobile': self.mobile_unregister,
                  'code': '9187'}
        if test_redis.get('sms:register:error_count:%s' % self.mobile_unregister):
            count_before = test_redis.get('sms:register:error_count:%s' % self.mobile_unregister)
        else:
            count_before = 0
        r = test(params)
        print r.content
        count_after = test_redis.get('sms:register:error_count:%s' % self.mobile_unregister)
        self.assertEqual(getmessage(r), u'验证码不正确')
        # list1 = [int(count_before)+1,getmessage(r)]
        # list2 = [int(count_after),u'验证码错误']
        # self.assertListEqual(list1,list2)
        self.assertEqual(int(count_before) + 1, int(count_after))

    def test_3(self):
        u"""注册账号：验证码过期"""
        self.case_id = 'test_3'
        code = getsms_code(1, '13540108163')
        # test_redis.delete('sms:register:%s' % '13540108163')
        test_redis.expire('sms:register:%s' % '13540108163', 3)
        time.sleep(5)
        # time.sleep(register_codetime('13540108163')+1)
        params = {'user_name': 'tester-Anry',
                  'password': '123456',
                  'mobile': '13540108163',
                  'code': code}
        r = test(params)
        print r.content
        self.assertEqual(getmessage(r), u'验证码不正确')

    def test_4(self):
        u"""注册账号:昵称字符多余10字"""
        self.case_id = 'test_4'
        code = getsms_code(1, self.mobile_unregister)
        print code
        time.sleep(2)
        params = {'user_name': 'tester-Anry我这么不知道这个事情啊你说说啊',
                  'password': '123456',
                  'mobile': self.mobile_unregister,
                  'code': code}
        r = test(params)
        print r.content
        self.assertEqual(getmessage(r), u'用户名格式不正确')

    def test_5(self):
        u"""注册账号:昵称字符少于2字"""
        self.case_id = 'test_5'
        code = getsms_code(1, self.mobile_unregister)
        time.sleep(2)
        params = {'user_name': '我',
                  'password': '123456',
                  'mobile': self.mobile_unregister,
                  'code': code}
        r = test(params)
        print r.content
        self.assertEqual(getmessage(r), u'用户名格式不正确')

    def test_6(self):
        u"""注册账号:昵称已存在"""
        self.case_id = 'test_6'
        code = getsms_code(1, self.mobile_unregister)
        time.sleep(2)
        params = {'user_name': 'tester',
                  'password': '123456',
                  'mobile': self.mobile_unregister,
                  'code': code}
        r = test(params)
        print r.content
        self.assertEqual(getmessage(r), u'用户名已存在')

    def test_7(self):
        u"""注册账号:密码少于6位"""
        self.case_id = 'test_7'
        code = getsms_code(1, self.mobile_unregister)
        time.sleep(2)
        username = 'test' + str(int(time.time()))[5:]
        params = {'user_name': username,
                  'password': '12345',
                  'mobile': self.mobile_unregister,
                  'code': code}
        r = test(params)
        if getcode(r) == 1:
            resetuser(username)
        print r.content
        self.assertEqual(getmessage(r), u'密码格式不正确')

    def test_8(self):
        u"""注册账号:密码多于18位"""
        self.case_id = 'test_8'
        code = getsms_code(1, self.mobile_unregister)
        time.sleep(2)
        username = 'test' + str(int(time.time()))[5:]
        params = {'user_name': username,
                  'password': '1234567890123456789',
                  'mobile': self.mobile_unregister,
                  'code': code}
        r = test(params)
        if getcode(r) == 1:
            resetuser(username)
        print r.content
        self.assertEqual(getmessage(r), u'密码格式不正确')

    def test_9(self):
        u"""注册账号:验证码少于4位"""
        self.case_id = 'test_9'
        username = 'test' + str(int(time.time()))[5:]
        params = {'user_name': username,
                  'password': '123456',
                  'mobile': self.mobile_unregister,
                  'code': 123}
        r = test(params)
        print r.content
        self.assertEqual(getmessage(r), u'验证码不正确')

    def test_10(self):
        u"""注册账号:验证码多于6位"""
        self.case_id = 'test_10'
        username = 'test' + str(int(time.time()))[5:]
        params = {'user_name': username,
                  'password': '123456',
                  'mobile': self.mobile_unregister,
                  'code': 1234567}
        r = test(params)
        print r.content
        self.assertEqual(getmessage(r), u'验证码不正确')

    def test_11(self):
        u"""注册账号:手机号已注册"""
        self.case_id = 'test_11'
        username = 'test' + str(int(time.time()))[5:]
        params = {'user_name': username,
                  'password': '123456',
                  'mobile': self.mobile,
                  'code': 1234}
        r = test(params)
        print r.content
        self.assertEqual(getmessage(r), u'手机号已注册')

    def test_12(self):
        u"""注册账号:手机号少于11"""
        self.case_id = 'test_12'
        username = 'test' + str(int(time.time()))[5:]
        params = {'user_name': username,
                  'password': '123456',
                  'mobile': '1354010816',
                  'code': 1234}
        r = test(params)
        print r.content
        self.assertEqual(getmessage(r), u'手机号格式不正确')

    def test_13(self):
        u"""注册账号:手机号多于11"""
        self.case_id = 'test_13'
        username = 'test' + str(int(time.time()))[5:]
        params = {'user_name': username,
                  'password': '123456',
                  'mobile': '135401081631',
                  'code': 1234}
        r = test(params)
        print r.content
        self.assertEqual(getmessage(r), u'手机号格式不正确')

    def test_14(self):
        u"""注册账号:手机号输入中文字符"""
        self.case_id = 'test_14'
        username = 'test' + str(int(time.time()))[5:]
        params = {'user_name': username,
                  'password': '123456',
                  'mobile': '中文字符',
                  'code': 1234}
        r = test(params)
        print r.content
        self.assertEqual(getmessage(r), u'手机号格式不正确')

    def test_15(self):
        u"""注册账号:手机号输入英文字符"""
        self.case_id = 'test_15'
        username = 'test' + str(int(time.time()))[5:]
        params = {'user_name': username,
                  'password': '123456',
                  'mobile': 'addfadf',
                  'code': 1234}
        r = test(params)
        print r.content
        self.assertEqual(getmessage(r), u'手机号格式不正确')

    def test_16(self):
        u"""注册账号:手机号输入特殊字符"""
        self.case_id = 'test_16'
        username = 'test' + str(int(time.time()))[5:]
        params = {'user_name': username,
                  'password': '123456',
                  'mobile': '&……%%%#$$%%',
                  'code': 1234}
        r = test(params)
        print r.content
        self.assertEqual(getmessage(r), u'手机号格式不正确')

    def test_17(self):
        u"""注册账号:手机号输入混合字符"""
        self.case_id = 'test_17'
        username = 'test' + str(int(time.time()))[5:]
        params = {'user_name': username,
                  'password': '123456',
                  'mobile': 'ad中文%#$$%%',
                  'code': 1234}
        r = test(params)
        print r.content
        self.assertEqual(getmessage(r), u'手机号格式不正确')

    def test_18(self):
        u"""注册账号:昵称字符为中文"""
        self.case_id = 'test_18'
        code = getsms_code(1, self.mobile_unregister)
        # print code
        time.sleep(2)
        params = {'user_name': '测试用户名',
                  'password': '123456',
                  'mobile': self.mobile_unregister,
                  'code': code}
        r = test(params)
        print r.content
        if getcode(r) == 1:
            resetuser('测试用户名')
            resetname('测试用户名')
        # self.assertEqual(getmessage(r), u'注册成功')
        self.assertEqual(getdata(r)['user_name'],u'测试用户名')

    def test_19(self):
        u"""注册账号:昵称字符为英文"""
        self.case_id = 'test_19'
        code = getsms_code(1, self.mobile_unregister)
        # print code
        time.sleep(2)
        params = {'user_name': 'testname',
                  'password': '123456',
                  'mobile': self.mobile_unregister,
                  'code': code}
        r = test(params)
        print r.content
        if getcode(r) == 1:
            resetuser('testname')
            resetname('testname')
        # self.assertEqual(getmessage(r), u'注册成功')
        self.assertEqual(getdata(r)['user_name'], 'testname')

    def test_20(self):
        u"""注册账号:昵称字符为特殊字符"""
        self.case_id = 'test_20'
        code = getsms_code(1, self.mobile_unregister)
        # print code
        time.sleep(2)
        params = {'user_name': '***@$',
                  'password': '123456',
                  'mobile': self.mobile_unregister,
                  'code': code}
        r = test(params)
        print r.content
        if getcode(r) == 1:
            resetuser('***@$')
            resetname('***@$')
        # self.assertEqual(getmessage(r), u'注册成功')
        self.assertEqual(getdata(r)['user_name'], '***@$')


    def test_21(self):
        u"""注册账号:密码为中文字符"""
        self.case_id = 'test_21'
        code = getsms_code(1, self.mobile_unregister)
        time.sleep(2)
        username = 'test' + str(int(time.time()))[5:]
        params = {'user_name': username,
                  'password': '中文长度够不够',
                  'mobile': self.mobile_unregister,
                  'code': code}
        r = test(params)
        if getcode(r) == 1:
            resetuser(username)
        print r.content
        self.assertEqual(getmessage(r), u'密码格式不正确')

    def test_22(self):
        u"""注册账号:密码为英文字符"""
        self.case_id = 'test_22'
        code = getsms_code(1, self.mobile_unregister)
        time.sleep(2)
        username = 'test' + str(int(time.time()))[5:]
        params = {'user_name': username,
                  'password': 'qweasdzxc',
                  'mobile': self.mobile_unregister,
                  'code': code}
        r = test(params)
        if getcode(r) == 1:
            resetuser(username)
        print r.content
        # self.assertEqual(getmessage(r), u'注册成功')
        self.assertEqual(getdata(r)['user_name'], username)


    def test_23(self):
        u"""注册账号:密码为数字字符"""
        self.case_id = 'test_23'
        code = getsms_code(1, self.mobile_unregister)
        time.sleep(2)
        username = 'test' + str(int(time.time()))[5:]
        params = {'user_name': username,
                  'password': '1234567890',
                  'mobile': self.mobile_unregister,
                  'code': code}
        r = test(params)
        if getcode(r) == 1:
            resetuser(username)
        print r.content
        # self.assertEqual(getmessage(r), u'注册成功')
        self.assertEqual(getdata(r)['user_name'], username)

    def test_24(self):
        u"""注册账号:密码为特殊字符"""
        self.case_id = 'test_24'
        code = getsms_code(1, self.mobile_unregister)
        time.sleep(2)
        username = 'test' + str(int(time.time()))[5:]
        params = {'user_name': username,
                  'password': '&*%$#$%$%$',
                  'mobile': self.mobile_unregister,
                  'code': code}
        r = test(params)
        if getcode(r) == 1:
            resetuser(username)
        print r.content
        # self.assertEqual(getmessage(r), u'注册成功')
        self.assertEqual(getdata(r)['user_name'], username)


    def test_25(self):
        u"""注册账号:密码为混合字符"""
        self.case_id = 'test_25'
        code = getsms_code(1, self.mobile_unregister)
        time.sleep(2)
        username = 'test' + str(int(time.time()))[5:]
        params = {'user_name': username,
                  'password': 'test@1234#$',
                  'mobile': self.mobile_unregister,
                  'code': code}
        r = test(params)
        if getcode(r) == 1:
            resetuser(username)
        print r.content
        # self.assertEqual(getmessage(r), u'注册成功')
        self.assertEqual(getdata(r)['user_name'], username)


    def test_26(self):
        u"""注册账号：验证码为中文"""
        self.case_id = 'test_26'
        username = 'test' + str(int(time.time()))[5:]
        params = {'user_name': username,
                  'password': '123456',
                  'mobile': self.mobile_unregister,
                  'code': '中文'}
        r = test(params)
        print r.content
        self.assertEqual(getmessage(r), u'验证码不正确')

    def test_27(self):
        u"""注册账号：验证码为英文"""
        self.case_id = 'test_27'
        username = 'test' + str(int(time.time()))[5:]
        params = {'user_name': username,
                  'password': '123456',
                  'mobile': self.mobile_unregister,
                  'code': 'test'}
        r = test(params)
        print r.content
        self.assertEqual(getmessage(r), u'验证码不正确')

    def test_28(self):
        u"""注册账号：验证码为特殊字符"""
        self.case_id = 'test_28'
        username = 'test' + str(int(time.time()))[5:]
        params = {'user_name': username,
                  'password': '123456',
                  'mobile': self.mobile_unregister,
                  'code': '&%$#'}
        r = test(params)
        print r.content
        self.assertEqual(getmessage(r), u'验证码不正确')


if __name__ == '__main__':
    unittest.main()
