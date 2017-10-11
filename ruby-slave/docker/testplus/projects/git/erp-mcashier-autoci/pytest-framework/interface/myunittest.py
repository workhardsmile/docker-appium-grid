#!/usr/bin/python
#-*- coding:utf-8 -*-
import StringIO
import logging
import traceback
import unittest
from testbasic import *
import testmain,json,time
from data.mysqldata import *

class TestCase(unittest.TestCase):
    case_id = ''
    status = 'Failed'

    def setUp(self):
        self.mobile = data[env]['user']['mobile']
        self.password = data[env]['user']['password']
        self.headers = getheaders(mobile=self.mobile, password=self.password)
        self.mobile_unregister = data[env]['user']['mobile_unregister']

        self.promobile = data[env]['user']['promobile']
        self.proheaders = getheaders(mobile=self.promobile, password=self.password)
        self.mobile_other = data[env]['user']['mobile_other']
        self.headersother = getheaders(mobile=self.mobile_other,password=self.password)
        self.userid = data[env]['user']['userid']
        self.useridother = data[env]['user']['useridother']
        self.prouserid = data[env]['user']['prouserid']
        self.adminuserid = data[env]['user']['adminuserid']

        self.topic_id = data[env]['testdata']['topic_id']

        self.admin_name = data[env]['user']['admin_name']
        self.admin_password = data[env]['user']['admin_password']
        self.adminheaders = getheaders(username=self.admin_name,password=self.admin_password)

        self.articles_id = getarticlesId(self.prouserid)


        self.article_id = getarticleId(self.prouserid)
        self.article_off_id = getarticleId(self.prouserid,-1)
        self.feature_id = data[env]['testdata']['feature_id']
        self.featureNull_id = data[env]['testdata']['featureNull_id']
        self.feature_id_online = data[env]['testdata']['feature_id_online']
        self.feature_id_off = data[env]['testdata']['feature_id_off']
        self.feature_id_other = data[env]['testdata']['feature_id_other']
        self.feature_id_saveanchor = data[env]['testdata']['feature_id_saveanchor']

        self.now = time.strftime("%Y%m%d%H%M%S", time.localtime(time.time()))
        self.now_short = time.strftime("%H%M%S", time.localtime(time.time()))

    def tearDown(self):
        fp = StringIO.StringIO()
        traceback.print_exc(file=fp)
        description = fp.getvalue()
        fp.close()
        # print description
        if description.strip('\n') == 'None':
            self.status = 'Passed'
            description = None
        else:
            # logging.error(description)
            logging.error(description.decode('unicode_escape'))
        logging.info("case_id：" + self.case_id)
        testmain.postcase(self.case_id, self.status, description)

    @classmethod
    def tearDownClass(cls):
        testmain.after()


# print getcommentId(222,7)