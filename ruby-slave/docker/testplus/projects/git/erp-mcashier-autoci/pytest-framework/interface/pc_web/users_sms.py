#!/usr/bin/python
# -*- coding:utf-8 -*-
import unittest
from interface import myunittest
from interface.testbasic import *
from interface.data.redisdata import *


def test(params,headers=None):
    r = ironhide().interfacetest('/api/website/users/sms', 'POST', params,headers,type='pc_web')
    return r

class test_users_sms(myunittest.TestCase):
    @classmethod
    def setUpClass(cls):
        reset_redis(data[env]['user']['mobile'])

    # 获取验证码
    def test_1(self):
        u"""获取注册验证码"""
        self.case_id = 'test_1'
        params = {'type': '1', 'mobile': self.mobile_unregister}
        r = test(params)
        print r.content
        self.assertEqual(getcode(r), 1)

    def test_2(self):
        u"""获取注册验证码：手机号位数不够"""
        self.case_id = 'test_2'
        params = {'type': '1', 'mobile': '1354010816'}
        r = test(params)
        print r.content
        self.assertEqual(getmessage(r), u'手机号格式不正确')

    def test_3(self):
        u"""获取注册验证码：已注册手机号"""
        self.case_id = 'test_3'
        params = {'type': '1', 'mobile': self.mobile}
        r = test(params)
        print r.content
        self.assertEqual(getmessage(r), u'手机号已注册')

    def test_4(self):
        u"""获取忘记密码验证码"""
        self.case_id = 'test_4'
        params = {'type': '2', 'mobile': self.mobile}
        r = test(params)
        print r.content
        self.assertEqual(getcode(r), 1)

    def test_5(self):
        u"""获取忘记密码验证码:手机号位数不够"""
        self.case_id = 'test_5'
        params = {'type': '2', 'mobile': '1354010816'}
        r = test(params)
        print r.content
        self.assertEqual(getmessage(r), u'手机号格式不正确')

    def test_6(self):
        u"""获取忘记密码验证码:未注册手机号"""
        self.case_id = 'test_6'
        params = {'type': '2', 'mobile': self.mobile_unregister}
        r = test(params)
        print r.content
        self.assertEqual(getmessage(r), u'手机号未注册')

    def test_7(self):
        u"""获取忘记密码验证码:手机号填写英文字符"""
        self.case_id = 'test_7'
        params = {'type': '2', 'mobile': 'dadfdfa'}
        r = test(params)
        print r.content
        self.assertEqual(getmessage(r), u'手机号格式不正确')

    def test_8(self):
        u"""获取忘记密码验证码:手机号填写中文字符"""
        self.case_id = 'test_8'
        params = {'type': '2', 'mobile': '中文版'}
        r = test(params)
        print r.content
        self.assertEqual(getmessage(r), u'手机号格式不正确')

    def test_9(self):
        u"""获取忘记密码验证码:手机号填写特殊字符"""
        self.case_id = 'test_9'
        params = {'type': '2', 'mobile': '@#￥%@'}
        r = test(params)
        print r.content
        self.assertEqual(getmessage(r), u'手机号格式不正确')

    def test_10(self):
        u"""获取忘记密码验证码:手机号超过11位"""
        self.case_id = 'test_10'
        params = {'type': '2', 'mobile': '135401081631'}
        r = test(params)
        print r.content
        self.assertEqual(getmessage(r), u'手机号格式不正确')

    def test_11(self):
        u"""未登录type填错（非1,2）"""
        self.case_id = 'test_11'
        params = {'type': '3', 'mobile': self.mobile_unregister}
        r = test(params)
        print r.content
        self.assertEqual(getmessage(r), u'请求类型不正确')

    def test_12(self):
        u"""登录状态type填错（非1,2,3,4）"""
        self.case_id = 'test_12'
        params = {'type': '-1', 'mobile': self.mobile}
        r = test(params, headers=self.headers)
        print r.content
        self.assertEqual(getmessage(r), u'请求类型不正确')

    def test_13(self):
        u"""重置密码：已登录，账号手机号和重置密码一致"""
        self.case_id = 'test_13'
        params = {'type': '3', 'mobile': self.mobile}
        r = test(params, headers=self.headers)
        print r.content
        self.assertEqual(getcode(r), 1)

    def test_14(self):
        u"""登录状态获取注册验证码"""
        self.case_id = 'test_14'
        params = {'type': '1', 'mobile': self.mobile}
        r = test(params, headers=self.headers)
        print r.content
        self.assertEqual(getmessage(r), u'请求类型不正确')

    def test_15(self):
        u"""登录状态获取忘记密码"""
        self.case_id = 'test_15'
        params = {'type': '2', 'mobile': self.mobile}
        r = test(params, headers=self.headers)
        print r.content
        self.assertEqual(getmessage(r), u'请求类型不正确')

    def test_16(self):
        u"""注册账号：验证码今日已获取10次"""
        self.case_id = 'test_16'
        params = {'type': '1', 'mobile': self.mobile_unregister}
        if register_success(self.mobile_unregister) != 10:
            now = register_success(self.mobile_unregister)
            test_redis.set('sms:register:success_count:%s' % self.mobile_unregister, 10)
        r = test(params)
        test_redis.set('sms:register:success_count:%s' % self.mobile_unregister, now)
        print r.content
        self.assertEqual(getmessage(r), u'短信验证码超过今日请求最大次数')

    def test_17(self):
        u"""注册账号：验证码错误已经5次"""
        self.case_id = 'test_17'
        params = {'type': '1', 'mobile': self.mobile_unregister}
        if register_error(self.mobile_unregister) != 5:
            now = register_error(self.mobile_unregister)
            test_redis.set('sms:register:error_count:%s' % self.mobile_unregister, 5)
        r = test(params)
        test_redis.set('sms:register:error_count:%s' % self.mobile_unregister, now)
        print r.content
        self.assertEqual(getmessage(r), u'短信验证码请求错误过多被禁止3小时')

    def test_18(self):
        u"""忘了密码：验证码今日已获取10次"""
        self.case_id = 'test_18'
        params = {'type': '2', 'mobile': self.mobile}
        if forget_success(self.mobile) != 10:
            now = forget_success(self.mobile)
            test_redis.set('sms:forget_password:success_count:%s' % self.mobile, 10)
        r = test(params)
        test_redis.set('sms:forget_password:success_count:%s' % self.mobile, now)
        print r.content
        self.assertEqual(getmessage(r), u'短信验证码超过今日请求最大次数')

    def test_19(self):
        u"""忘记密码：验证码错误已经5次"""
        self.case_id = 'test_19'
        params = {'type': '2', 'mobile': self.mobile}
        if forget_error(self.mobile) != 5:
            now = forget_error(self.mobile)
            test_redis.set('sms:forget_password:error_count:%s' % self.mobile, 5)
        r = test(params)
        test_redis.set('sms:forget_password:error_count:%s' % self.mobile, now)
        print r.content
        self.assertEqual(getmessage(r), u'短信验证码请求错误过多被禁止3小时')

    def test_20(self):
        u"""重置密码：验证码今日已获取10次"""
        self.case_id = 'test_20'
        params = {'type': '3', 'mobile': self.mobile}
        if update_success(self.mobile) != 10:
            now = update_success(self.mobile)
            test_redis.set('sms:update_password:success_count:%s' % self.mobile, 10)
        r = test(params, headers=self.headers)
        test_redis.set('sms:update_password:success_count:%s' % self.mobile, now)
        print r.content
        self.assertEqual(getmessage(r), u'短信验证码超过今日请求最大次数')

    def test_21(self):
        u"""重置密码：验证码错误已经5次"""
        self.case_id = 'test_21'
        params = {'type': '3', 'mobile': self.mobile}
        if update_error(self.mobile) != 5:
            now = update_error(self.mobile)
            test_redis.set('sms:update_password:error_count:%s' % self.mobile, 5)
        r = test(params, headers=self.headers)
        test_redis.set('sms:update_password:error_count:%s' % self.mobile, now)
        print r.content
        self.assertEqual(getmessage(r), u'短信验证码请求错误过多被禁止3小时')

    def test_22(self):
        u"""重置密码：已登录，账号手机号(已注册）和重置密码不一致"""
        self.case_id = 'test_22'
        # params = {'type': '3', 'mobile': self.mobile_unregister}
        params = {'type': '3', 'mobile': '13730731514'}
        # if update_error(self.mobile) != 5:
        #     now = update_error(self.mobile)
        #     test_redis.set('sms:update_password:error_count:%s'%self.mobile,5)
        r = test(params, headers=self.headers)
        # test_redis.set('sms:update_password:error_count:%s'%self.mobile,now)
        print r.content
        self.assertEqual(getmessage(r), u'手机号不匹配')

    def test_23(self):
        u"""重置密码：已登录，账号手机号(未注册）和重置密码不一致"""
        self.case_id = 'test_23'
        # params = {'type': '3', 'mobile': self.mobile_unregister}
        params = {'type': '3', 'mobile': '13800138000'}
        # if update_error(self.mobile) != 5:
        #     now = update_error(self.mobile)
        #     test_redis.set('sms:update_password:error_count:%s'%self.mobile,5)
        r = test(params, headers=self.headers)
        # test_redis.set('sms:update_password:error_count:%s'%self.mobile,now)
        print r.content
        self.assertEqual(getmessage(r), u'手机号未注册')

    def test_24(self):
        u"""登录状态type填4"""
        self.case_id = 'test_24'
        params = {'type': '4', 'mobile': self.mobile}
        r = test(params, headers=self.headers)
        print r.content
        self.assertEqual(getcode(r), 1)

if __name__ == '__main__':
    unittest.main()
