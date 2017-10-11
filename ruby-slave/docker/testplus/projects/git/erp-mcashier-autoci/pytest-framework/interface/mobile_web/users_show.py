# -*- coding:utf-8 -*-
import unittest
from interface import myunittest
from interface.testbasic import *


def test(params,headers=None):
    r = ironhide().interfacetest('/api/h5/users/show', 'GET', params,headers)
    return r

class test_users_show(myunittest.TestCase):
    # 个人信息
    def test_1(self):
        u"""非登录状态个人信息"""
        self.case_id = 'test_1'
        params = {'user_id':self.userid}
        r = test(params)
        print r.content
        self.assertEqual(getcode(r), 1)

    def test_2(self):
        u"""登录状态获取个人信息(非专家)"""
        self.case_id = 'test_2'
        params = {'user_id':self.userid}
        r = test(params,headers = self.headers)
        print r.content
        self.assertEqual(getcode(r), 1)
        self.assertEqual(getdata(r).get('is_expert'),0)


    def test_3(self):
        u"""登录状态获取个人信息(专家)"""
        self.case_id = 'test_3'
        params = {'user_id':self.prouserid}
        r = test(params,headers = self.headers)
        print r.content
        self.assertEqual(getcode(r), 1)
        self.assertEqual(getdata(r).get('is_expert'),1)


if __name__ == '__main__':
    unittest.main()
