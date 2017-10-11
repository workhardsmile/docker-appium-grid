#-*- coding:utf-8 -*-
from interface.testbasic import *
import unittest
from interface import myunittest


def test(params,headers=None):
    r = ironhide().interfacetest('/api/mobile/v1/users/sign_in', 'POST', params,headers)
    return r

class test_sign_in(myunittest.TestCase):
    # 登录
    def test_1(self):
        u"""正常登录"""
        self.case_id = 'test_1'
        params = {'mobile': self.mobile, 'password': self.password}
        r = test(params)
        # print params
        print r.content
        self.assertEqual(getcode(r), 1)
        self.assertEqual(getdata(r).get('is_expert'),0)


    def test_2(self):
        u"""密码错误登录"""
        self.case_id = 'test_2'
        params = {'mobile': self.mobile, 'password': '12345'}
        r = test(params)
        self.assertEqual(getmessage(r), u'账号或密码不正确')

    def test_3(self):
        u"""手机号错误登录"""
        self.case_id = 'test_3'
        params = {'mobile': '1898070902', 'password': self.password}
        r = test(params)
        self.assertEqual(getmessage(r), u'账号或密码不正确')

    def test_4(self):
        u"""手机号密码均错误登录"""
        self.case_id = 'test_4'
        params = {'mobile': '1898070902', 'password': '12345'}
        r = test(params)
        # print r.content
        self.assertEqual(getmessage(r), u'账号或密码不正确')

    def test_5(self):
        u"""手机号填写中文字符"""
        self.case_id = 'test_5'
        params = {'mobile': '测试', 'password': self.password}
        r = test(params)
        print r.content
        self.assertEqual(getmessage(r), u'账号或密码不正确')

    def test_6(self):
        u"""手机号填写英文字符"""
        self.case_id = 'test_6'
        params = {'mobile': 'test', 'password': self.password}
        r = test(params)
        print r.content
        self.assertEqual(getmessage(r), u'账号或密码不正确')

    def test_7(self):
        u"""手机号填写特殊字符"""
        self.case_id = 'test_7'
        params = {'mobile': '#￥%', 'password': self.password}
        r = test(params)
        print r.content
        self.assertEqual(getmessage(r), u'账号或密码不正确')

    def test_8(self):
        u"""手机号填写混合字符"""
        self.case_id = 'test_8'
        params = {'mobile': '文海jkfd2388#￥%', 'password': self.password}
        r = test(params)
        print r.content
        self.assertEqual(getmessage(r), u'账号或密码不正确')

    def test_9(self):
        u"""手机号超11位"""
        self.case_id = 'test_9'
        params = {'mobile': '189807090201', 'password': self.password}
        r = test(params)
        print r.content
        self.assertEqual(getmessage(r), u'账号或密码不正确')

    def test_10(self):
        u"""密码填写英文字符"""
        self.case_id = 'test_10'
        params = {'mobile': self.mobile, 'password': 'fddsd'}
        r = test(params)
        print r.content
        self.assertEqual(getmessage(r), u'账号或密码不正确')

    def test_11(self):
        u"""密码填写中文字符"""
        self.case_id = 'test_11'
        params = {'mobile': self.mobile, 'password': '测试'}
        r = test(params)
        print r.content
        self.assertEqual(getmessage(r), u'账号或密码不正确')

    def test_12(self):
        u"""密码填写混合字符"""
        self.case_id = 'test_12'
        params = {'mobile': self.mobile, 'password': '测试dfj$#&'}
        r = test(params)
        print r.content
        self.assertEqual(getmessage(r), u'账号或密码不正确')

    def test_13(self):
        u"""密码填写特殊字符"""
        self.case_id = 'test_13'
        params = {'mobile': self.mobile, 'password': '%￥#$#'}
        r = test(params)
        print r.content
        self.assertEqual(getmessage(r), u'账号或密码不正确')

    def test_14(self):
        u"""密码填写超过18位"""
        self.case_id = 'test_14'
        params = {'mobile': self.mobile, 'password': 'asdqwe123!@#qweasd123'}
        r = test(params)
        print r.content
        self.assertEqual(getmessage(r), u'账号或密码不正确')

    def test_15(self):
        u"""密码填写为空"""
        self.case_id = 'test_15'
        params = {'mobile': self.mobile, 'password': ''}
        r = test(params)
        print r.content
        self.assertEqual(getmessage(r), u'账号或密码不正确')

    def test_16(self):
        u"""手机号填写为空"""
        self.case_id = 'test_16'
        params = {'mobile': '', 'password': self.password}
        r = test(params)
        print r.content
        self.assertEqual(getmessage(r), u'账号或密码不正确')

    def test_17(self):
        u"""专家登录"""
        self.case_id = 'test_17'
        params = {'mobile': self.promobile, 'password': self.password}
        r = test(params)
        print r.content
        self.assertEqual(getdata(r).get('is_expert'),1)



if __name__ == '__main__':
    unittest.main()
