#!/usr/bin/python
#-*- coding:utf-8 -*-
import unittest
import HTMLTestRunner,time
import sys,json,os
sys.path.append(os.path.dirname(os.path.dirname(__file__)))
from testplus.testplus_api import *
# import logging
# from common import logger

dic = {}
if sys.argv != None and len(sys.argv) > 3:
    for i in range(1, len(sys.argv)-1,2):
        # print  i, sys.argv[i]
        dic = dict(dic,**{sys.argv[i]:sys.argv[i+1]})
        # dic = {sys.argv[i]:sys.argv[i+1]}
    # print dic

    env_input = dic.get('-e')
    # print env_input
    script_path = dic.get('-s')
    # print script_path
    round_id = dic.get('-r')
    # print round_id
    platform = dic.get('-p')
    # print platform
    output = dic.get('-o')
    # print output
    myip = dic.get('-i')
    # print output
    if script_path != None:
        script_run = script_path.split('-')[-1] + '.py'
        script_name = script_path.split('/')[-1]
        script_path = script_path.split('-')[:-1]
        script_path = '-'.join(script_path)
        # script_path = os.path.dirname(script_path)
        # script_path = script_path.split('/')[-2]

def get_log_json():
    log_json = dic.get('-j')
    return json.loads(log_json)

def get_filename():
    if dic != {}:
        server_log = get_log_json()['log']['file_name']+'.txt'
    elif dic == {}:
        server_log = 'testlog.txt'
    return server_log

def getenv():
    if dic == {}:
        enviroment = 'QA'
        # enviroment = 'STG'
    elif dic != {}:
        enviroment = env_input
    return enviroment


def get_logfile():
    logfile = os.path.dirname(__file__) + '/../output/test_results/' + get_filename()
    # print logfile
    return logfile
# get_logfile()

def get_script_result():
    script_result = {"round_id": round_id,
                     "script_name": script_name,
                     "status": "end",
                     "versions": "IronhideWeb#1.1.0|IronhideAndroid#1.1.0"}
    print script_result
    return script_result


def get_case_result(case_id,status,description=None):
    # server_log = get_filename()
    case_result = {"round_id":round_id,
                   "case_id":case_id,
                   "status":status,
                   "description": description,
                   "script_name":script_name,
                   "screen_shot":"",
                   "server_log":get_filename()
                   }
    print case_result
    return case_result

def suit():
    loader = unittest.TestLoader()
    suite = loader.discover(script_path,pattern=script_run)
    # suite = loader.discover(script_path,pattern=script_name+'.py')
    # print script_run,script_path
    # print suite
    return suite

if dic != {}:
    # now = time.strftime("%Y-%m-%d-%H_%M_%S",time.localtime(time.time()))
    #
    # # filename = './interface/report/'+ now +'_mobileWeb_result.html'
    # filename = './report/'+ now +'_mobileWeb_result.html'
    # fp = file(filename,'wb')
    #
    # runner = HTMLTestRunner.HTMLTestRunner(
    #     stream=fp,
    #     title=u'ironhide接口测试报告',
    #     description = u'用例执行情况：'
    # )
    runner = unittest.TextTestRunner()
    runner.run(suit())

# print get_case_result('IH488', 'Failed')
# print get_script_result()
# print get_log_json()

def postcase(case_id,status,description=None):
    result = TestPlusAPI()
    if dic != {}:
        caseresutlt = get_case_result(case_id, status,description)
        result.post_case_result(caseresutlt)

def after():
    result = TestPlusAPI()
    if dic != {}:
        scriptresult = get_script_result()
        result.post_script_status(scriptresult, get_log_json())


