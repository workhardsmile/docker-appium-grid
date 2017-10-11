#!/usr/bin/python
#-*- coding:utf-8 -*-

from locust import *
from interface.testbasic import ironhide

class mytest(TaskSet):
    @task(weight=1)
    def test_1(self):
        dt={'user_id':'23'}
        headers = ironhide().gettoken('tester','123456')
        with self.client.get(name='get', url='/api/mobile/v1/users/show', data=dt,catch_response=True,headers=headers) as response:
            # print response.content
            if '1' in response.content:
                response.success()
            else:
                response.failure('error')

    @task(weight=1)
    def test_2(self):
        dt = {
            'mobile': '18980709020',
            # 'mobile': '13540108163',
            'password': '123456'
        }

        with self.client.post(name='post', url='/api/mobile/v1/users/sign_in', data=dt, catch_response=True) as response:
            # print response.content
            if '1' in response.content:
                response.success()
            else:
                response.failure('error')


class myrun(HttpLocust):
    task_set = mytest
    host = 'http://192.168.28.218'
    # host = 'http://www.wulianaq.com'
    min_wait = 0
    max_wait = 0

