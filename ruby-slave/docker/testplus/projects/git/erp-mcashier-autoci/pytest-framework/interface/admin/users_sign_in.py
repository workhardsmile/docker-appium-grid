#!/usr/bin/python
# -*- coding:utf-8 -*-
from interface.testbasic import *
import unittest
from interface import myunittest


def test(params,headers=None):
    r = ironhide().interfacetest('/api/admin/users/sign_in', 'POST', params,headers,type='admin')
    return r


class test_users_sign_in(myunittest.TestCase):
    # 用户登录
    def test_1(self):
        u"""正常登录"""
        self.case_id = 'test_1'
        params = {'user_name':self.admin_name,'password':self.admin_password}
        r = test(params)
        print r.content
        self.assertEqual(getdata(r)['user_name'], self.admin_name)

    def test_2(self):
        u"""密码错误登录"""
        self.case_id = 'test_2'
        params = {'mobile': self.admin_name, 'password': '12345'}
        r = test(params)
        self.assertEqual(getmessage(r), u'账号或密码不正确')

    def test_3(self):
        u"""用户名错误登录"""
        self.case_id = 'test_3'
        params = {'mobile': 'smar', 'password': self.admin_password}
        r = test(params)
        self.assertEqual(getmessage(r), u'账号或密码不正确')

    def test_4(self):
        u"""用户名密码均错误登录"""
        self.case_id = 'test_4'
        params = {'mobile': 'smar', 'password': '12345'}
        r = test(params)
        # print r.content
        self.assertEqual(getmessage(r), u'账号或密码不正确')


    def test_5(self):
        u"""密码填写英文字符"""
        self.case_id = 'test_5'
        params = {'mobile': self.admin_name, 'password': 'fddsd'}
        r = test(params)
        print r.content
        self.assertEqual(getmessage(r), u'账号或密码不正确')

    def test_6(self):
        u"""密码填写中文字符"""
        self.case_id = 'test_6'
        params = {'mobile': self.admin_name, 'password': '测试'}
        r = test(params)
        print r.content
        self.assertEqual(getmessage(r), u'账号或密码不正确')

    def test_7(self):
        u"""密码填写混合字符"""
        self.case_id = 'test_7'
        params = {'mobile': self.admin_name, 'password': '测试dfj$#&'}
        r = test(params)
        print r.content
        self.assertEqual(getmessage(r), u'账号或密码不正确')

    def test_8(self):
        u"""密码填写特殊字符"""
        self.case_id = 'test_8'
        params = {'mobile': self.admin_name, 'password': '%￥#$#'}
        r = test(params)
        print r.content
        self.assertEqual(getmessage(r), u'账号或密码不正确')

    def test_9(self):
        u"""密码填写超过18位"""
        self.case_id = 'test_9'
        params = {'mobile': self.admin_name, 'password': 'asdqwe123!@#qweasd123'}
        r = test(params)
        print r.content
        self.assertEqual(getmessage(r), u'账号或密码不正确')

    def test_10(self):
        u"""密码填写为空"""
        self.case_id = 'test_10'
        params = {'mobile': self.admin_name, 'password': ''}
        r = test(params)
        print r.content
        self.assertEqual(getmessage(r), u'账号或密码不正确')

    def test_11(self):
        u"""用户名填写为空"""
        self.case_id = 'test_11'
        params = {'mobile': '', 'password': self.password}
        r = test(params)
        print r.content
        self.assertEqual(getmessage(r), u'账号或密码不正确')




if __name__ == '__main__':
    unittest.main()
