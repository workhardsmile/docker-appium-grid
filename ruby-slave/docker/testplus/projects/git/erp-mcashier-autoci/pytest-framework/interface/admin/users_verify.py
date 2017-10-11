#!/usr/bin/python
# -*- coding:utf-8 -*-
from interface.testbasic import *
import unittest
from interface import myunittest


def test(params,headers=None):
    r = ironhide().interfacetest('/api/admin/users/verify', 'POST', params,headers,type='admin')
    return r


class test_users_verify(myunittest.TestCase):
    def setUp(self):
        myunittest.TestCase.setUp(self)
        self.mobile_verify = data[env]['user']['mobile_verify']
        self.userid_verify = data[env]['user']['userid_verify']
        resetRole(self.userid_verify)

    def apply(self,step=2):
        if step == 2:
            apply_step1(type=1, headers=getheaders(mobile=self.mobile_verify, password=self.password))
            apply_step2(user_id=self.userid_verify, headers=getheaders(mobile=self.mobile_verify, password=self.password))
        elif step == 1:
            apply_step1(type=1, headers=getheaders(mobile=self.mobile_verify, password=self.password))


    # 安全号申请-审核
    def test_1(self):
        u"""未登录审核安全号"""
        self.case_id = 'test_1'
        params = {'apply_id':'11',
                  'status':'-1',
                  'reason':'审核未通过'}
        r = test(params)
        print r.content
        self.assertEqual(getmessage(r), u'请重新登录')

    def test_2(self):
        u"""登录审核安全号：未通过"""
        self.case_id = 'test_2'
        self.apply()
        apply_id = getApplyId(0,self.userid_verify)
        params = {'apply_id': apply_id,
                  'status': '-1',
                  'reason': '审核未通过'}
        r = test(params,headers=self.adminheaders)
        self.assertEqual(getcode(r), 1)

    def test_3(self):
        u"""登录审核安全号：通过"""
        self.case_id = 'test_3'
        self.apply()
        apply_id = getApplyId(0,self.userid_verify)
        params = {'apply_id': apply_id,
                  'status': '1',
                  'reason': '审核通过'}
        r = test(params,headers=self.adminheaders)
        self.assertEqual(getcode(r), 1)

    def test_4(self):
        u"""登录审核安全号：apply_id为空"""
        self.case_id = 'test_4'
        params = {'apply_id': '',
                  'status': '1',
                  'reason': '审核通过'}
        r = test(params,headers=self.adminheaders)
        self.assertEqual(getmessage(r),u'安全号申请不存在')

    def test_5(self):
        u"""登录审核安全号：apply_id错误"""
        self.case_id = 'test_5'
        params = {'apply_id': '-1',
                  'status': '1',
                  'reason': '审核通过'}
        r = test(params,headers=self.adminheaders)
        self.assertEqual(getmessage(r),u'安全号申请不存在')

    def test_6(self):
        u"""登录审核安全号：status错误"""
        self.case_id = 'test_6'
        self.apply()
        apply_id = getApplyId(0,self.userid_verify)
        params = {'apply_id': apply_id,
                  'status': '0',
                  'reason': '审核未通过'}
        r = test(params,headers=self.adminheaders)
        self.assertEqual(getmessage(r),u'审核状态不正确')

    def test_7(self):
        u"""登录审核安全号：未提交第二步审核未通过"""
        self.case_id = 'test_7'
        self.apply(step=1)
        apply_id = getApplyId(-2,self.userid_verify)
        params = {'apply_id': apply_id,
                  'status': '-1',
                  'reason': '审核未通过'}
        r = test(params,headers=self.adminheaders)
        self.assertEqual(getmessage(r),u'安全号申请资料未完善')

    def test_8(self):
        u"""登录审核安全号：未提交第二步审核未通过"""
        self.case_id = 'test_8'
        self.apply(step=1)
        apply_id = getApplyId(-2,self.userid_verify)
        params = {'apply_id': apply_id,
                  'status': '1',
                  'reason': '审核通过'}
        r = test(params,headers=self.adminheaders)
        self.assertEqual(getmessage(r),u'安全号申请资料未完善')

    def test_9(self):
        u"""登录审核安全号：未通过再通过"""
        self.case_id = 'test_9'
        self.apply()
        apply_id = getApplyId(0,self.userid_verify)
        params = {'apply_id': apply_id,
                  'status': '-1',
                  'reason': '审核未通过'}
        r = test(params,headers=self.adminheaders)
        params2 = {'apply_id': apply_id,
                  'status': '1',
                  'reason': '审核通过'}
        r = test(params2,headers=self.adminheaders)
        self.assertEqual(getmessage(r),u'安全号申请未通过')

    def test_10(self):
        u"""登录审核安全号：通过再未通过"""
        self.case_id = 'test_10'
        self.apply()
        apply_id = getApplyId(0,self.userid_verify)
        params = {'apply_id': apply_id,
                  'status': '1',
                  'reason': '审核通过'}
        r = test(params,headers=self.adminheaders)
        params2 = {'apply_id': apply_id,
                   'status': '-1',
                   'reason': '审核未通过'}
        r = test(params2, headers=self.adminheaders)
        self.assertEqual(getmessage(r),u'安全号申请已通过')

    def test_11(self):
        u"""登录审核安全号：未通过原因未填"""
        self.case_id = 'test_11'
        self.apply()
        apply_id = getApplyId(0,self.userid_verify)
        params = {'apply_id': apply_id,
                  'status': '-1',
                  'reason': ''}
        r = test(params,headers=self.adminheaders)
        self.assertEqual(getmessage(r),u'安全号申请审核未通过原因不能为空')

    def test_12(self):
        u"""登录审核安全号：通过原因未填"""
        self.case_id = 'test_12'
        self.apply()
        apply_id = getApplyId(0,self.userid_verify)
        params = {'apply_id': apply_id,
                  'status': '1',
                  'reason': ''}
        r = test(params,headers=self.adminheaders)
        self.assertEqual(getcode(r), 1)


if __name__ == '__main__':
    unittest.main()
