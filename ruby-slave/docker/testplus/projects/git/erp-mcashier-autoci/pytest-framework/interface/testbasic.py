#!/usr/bin/python
#-*- coding:utf-8 -*-

import json,requests,hashlib,random
from urllib import quote
from interface.data.redisdata import *
import logging,time
from common import logger
# from common.logger import *
import testmain
from interface.data.mysqldata import *


# from interface.data.redisdata import *

from distutils.version import LooseVersion

class ironhide():
    def __init__(self):
        # self.url = 'http://192.168.28.218'
        self.url = data[env]['server']['url']
        # self.api_host = '192.168.28.218'
        self.api_host = data[env]['server']['host']
        # self.mobile = '18980709020'
        self.mobile = data[env]['user']['mobile']
        # self.password = '123456'
        self.password = data[env]['user']['password']

        self.token=''
        self.appVersion = '1.1.0'
        # self.appVersion = '1.0.0'
        self.systemType = 'Andriod'
        self.systemInfo = '5.1'
        self.deviceModel = 'm2 note'
        self.Device_Info = self.setDevice_Info(self.appVersion,self.systemType,self.systemInfo,self.deviceModel)
        # self.Device_Info = ''
        self.headers = {
                    'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
                   'Connection': 'Keep-Alive',
                   # 'Referer': 'http://' + self.api_host,
                   # 'User-Agent': 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/49.0.2623.110 Safari/537.36'
                   # 'User-Agent': 'Dalvik/2.1.0 (Linux; U; Android 6.0; MI 5 MIUI/V7.5.6.0.MAACNDE)'
                   }

    def settoken(self,token):
        self.token = token

    def setuser(self,mobile,password):
        self.mobile = mobile
        self.password = password

    def seturl(self,url):
        self.url = url

    def setDevice_Info(self,appVersion, systemType, systemInfo, deviceModel):
        self.appVersion = appVersion
        self.systemType = systemType
        self.systemInfo = systemInfo
        self.deviceModel = deviceModel
        Device_Info = "appVersion=%s;systemType=%s;systemInfo=%s;deviceModel=%s" % (appVersion, systemType, systemInfo, deviceModel)
        self.Device_Info = {"Device-Info": Device_Info}
        return self.Device_Info

    def getsign(self,api, method, params, token):
        secretKey = '65a231f31de9330780942b109692e5a1e2a779b51781349aaea2dae44958a1d644a803af21bbb318695e58b758f94e7aa3a5450a3f7092f6e05ea172d9b95043'
        method = method.lower()
        m = hashlib.md5()
        # sortedparams = json.dumps(params, sort_keys=True)

        dic = sorted(params)
        string = ''
        for i in dic:
            for k, v in params.items():
                if k == i:
                    string = string + str(k) + '=' + str(v) +'&'
                    # string = string + quote(str(k)) + '=' + quote(str(v)) + '&''
        # if string.endswith('&&'):
        #     string = string[:-1]
        # else:
        #     string = string.strip('&')
        # print string

        if token == '':
            if string.endswith('&&'):
                m.update((secretKey + '&' + method + '&' + api + '&' + string[:-1]))
            else:
                m.update((secretKey + '&' + method + '&' + api + '&' + string).strip('&'))


        else:
            if string.endswith('&&'):
                m.update((secretKey + '&' + token + '&' + method + '&' + api + '&' + string[:-1]))
            else:
                m.update((secretKey + '&' + token + '&' + method + '&' + api + '&' + string).strip('&'))

        sign = m.hexdigest()
        # print string,sign
        headers = {"Sign": sign}
        return headers

    def gettoken(self, password,mobile=None,username=None,type = 'app'):
        if type == 'app':
            api = '/api/mobile/v1/users/sign_in'
        elif type == 'pc_web':
            api = '/api/website/users/sign_in'
        elif type == 'admin':
            api = '/api/admin/users/sign_in'
        # elif type == 'mobile_web':
        #     api == ''
        url = self.url + api

        if mobile != None and username == None:
            params = {'mobile': mobile, 'password': password}
        elif username != None and mobile == None:
            params = {'user_name': username, 'password': password}

        token = ''

        if LooseVersion(self.appVersion) >= LooseVersion('1.1.0'):
            sign = self.getsign(api,'POST',params,token)
            headers = dict(self.headers,**self.Device_Info)
            headers = dict(headers,**sign)
        else:
            headers = self.headers

        r = requests.post(url,data=params,headers=headers)
        # print r.content
        self.token = r.headers.get('access_token')
        # print self.token
        headers = {'Authorization': 'Token token=%s' % self.token}

        return headers


    def gettoken_identity(self, password,mobile=None,username=None,type = 'app',user_id=None):
        if type == 'app':
            api = '/api/mobile/v1/users/sign_in'
        elif type == 'pc_web':
            api = '/api/website/users/sign_in'
        elif type == 'admin':
            api = '/api/admin/users/sign_in'
        # elif type == 'mobile_web':
        #     api == ''
        url = self.url + api

        if mobile != None and username == None:
            params = {'mobile': mobile, 'password': password}
        elif username != None and mobile == None:
            params = {'user_name': username, 'password': password}

        token = ''

        if LooseVersion(self.appVersion) >= LooseVersion('1.1.0'):
            sign = self.getsign(api,'POST',params,token)
            headers = dict(self.headers,**self.Device_Info)
            headers = dict(headers,**sign)
        else:
            headers = self.headers

        r = requests.post(url,data=params,headers=headers)
        # print r.content
        # resheaders = r.headers
        self.token = r.headers.get('access_token')
        # print self.token
        # headers = {'AdminAuthorization': 'Token token=%s' % self.token,'Authorization': 'Token token=%s' % self.token}
        headers = {'Authorization': 'Token token=%s' % self.token}


        api_identity = '/api/website/users/identity'
        params_identity = {'user_id':user_id}
        url_identity = self.url + api_identity
        r_identity = requests.get(url_identity,params_identity,headers=headers)
        token_identity = r_identity.headers.get('access_token')
        headers = {'AdminAuthorization': 'Token token=%s' % self.token,'Authorization': 'Token token=%s' % token_identity}

        return headers



    def interfacetest(self,api,method,params,headers=None,s=None,type='app'):
        # print headers
        if LooseVersion(self.appVersion) >= LooseVersion('1.1.0'):
            if headers == None:
                headers = {}
                token = ''
            else:
                if headers.get('mobile'):
                    # headers = self.gettoken(mobile=headers.get('mobile'),password=headers.get('password'),type=type)
                    headers = self.gettoken(mobile=headers['mobile'],password=headers['password'],type=type)
                # elif headers.get('user_name'):
                #     headers = self.gettoken(username=headers.get('user_name'), password=headers.get('password'),type=type)
                elif headers.get('user_name'):
                    if type == 'admin':
                        # headers = self.gettoken(username=headers.get('user_name'), password=headers.get('password'),type=type)
                        headers = self.gettoken(username=headers['user_name'], password=headers['password'],type=type)
                    elif type == 'pc_web':
                        if api == '/api/website/users/identity':
                            headers = self.gettoken(username=headers['user_name'],password=headers['password'], type='admin')
                        else:
                            headers = self.gettoken_identity(username=headers['user_name'], password=headers['password'],type='admin',user_id=headers['user_id'])


                # headers = self.gettoken(self.mobile, self.password)
                token = self.token
                # print self.token
            headers = dict(self.headers,**headers)
            if type == 'app':
                sign = self.getsign(api,method,params,token)
                headers = dict(headers,**sign)
                headers = dict(headers,**self.Device_Info)
        else:
            if headers == None:
                headers = self.headers
            else:
                headers = dict(self.headers,**headers)
        # print headers

        if s == None:
            s = requests.session()
        r = ''
        if method == 'POST':
            r = s.post(self.url+api,data=params,headers = headers)
            # print r.content
        elif method == 'GET':
            r = s.get(self.url+api,params=params,headers=headers)
        elif method == 'PUT':
            r = s.put(self.url + api, params=params, headers=headers)
        elif method == 'DELETE':
            r = s.delete(self.url + api, params=params, headers=headers)

        logging.info(method+' ' + self.url+api)
        logging.info('headers:' + json.dumps(headers))
        logging.info('params:' + json.dumps(params).decode('unicode_escape'))
        logging.info('response:' + r.content)
        return r




def getcode(r):
    code = json.loads(r.content).get('code')
    # print code
    return code


def getdata(r):
    data = json.loads(r.content).get('data')
    # print data
    return data


def getmessage(r):
    message = json.loads(r.content).get('message')
    # print message
    return message

def getheaders(password,mobile=None,username=None,user_id=None):
    if mobile != None and username == None:
        user = {'mobile': mobile, 'password': password}
    elif username != None and mobile == None:
        user = {'user_name':username,'password': password,'user_id':user_id}
    return user

def getsms_code(type,mobile,password=None):
    params = {'type': type, 'mobile': mobile}
    if type == 1:
        ironhide().interfacetest('/api/mobile/v1/users/sms', 'POST', params)
        code = register_code(mobile)
    elif type == 2:
        ironhide().interfacetest('/api/mobile/v1/users/sms', 'POST', params)
        code = forget_code(mobile)
    elif type == 3:
        test = ironhide()
        test.setuser(mobile,password)
        # ironhide().interfacetest('/api/mobile/v1/users/sms', 'POST', params,headers=getheaders(mobile,password))
        test.interfacetest('/api/mobile/v1/users/sms', 'POST', params,headers=getheaders(mobile=mobile,password=password))
        code = update_code(mobile)
    elif type == 4:
        ironhide().interfacetest('/api/mobile/v1/users/sms', 'POST', params,headers=getheaders(mobile=mobile,password=password))
        code = apply_code(mobile)
    return code


def createtimeSort(r):
    j = 0
    for i in range(0, len(getdata(r)['list']) - 1):
        if getdata(r)['list'][i]['created_at'] >= getdata(r)['list'][i + 1]['created_at']:
            j += 1
    j = j + 1
    return j

def updatetimeSort(r):
    j = 0
    for i in range(0, len(getdata(r)['list']) - 1):
        if getdata(r)['list'][i]['updated_at'] >= getdata(r)['list'][i + 1]['updated_at']:
            j += 1
    j = j + 1
    return j

def voteSort(r):
    j = 0
    for i in range(0, len(getdata(r)['list']) - 1):
        if getdata(r)['list'][i]['vote_count'] > getdata(r)['list'][i + 1]['vote_count']:
            j += 1
        elif getdata(r)['list'][i]['vote_count'] == getdata(r)['list'][i + 1]['vote_count']:
            if getdata(r)['list'][i]['created_at'] >= getdata(r)['list'][i + 1]['created_at']:
                j += 1
    j = j + 1
    return j

def commentSort(r):
    j = 0
    for i in range(0, len(getdata(r)['list']) - 1):
        if getdata(r)['list'][i]['comment_count'] >= getdata(r)['list'][i + 1]['comment_count']:
            j += 1
        elif getdata(r)['list'][i]['comment_count'] == getdata(r)['list'][i + 1]['comment_count']:
            if getdata(r)['list'][i]['created_at'] >= getdata(r)['list'][i + 1]['created_at']:
                j += 1
    j = j + 1
    return j

def scoreSort(r):
    j = 0
    for i in range(0, len(getdata(r)['list']) - 1):
        if getdata(r)['list'][i]['rak'] > getdata(r)['list'][i + 1]['rak']:
            j += 1
        elif getdata(r)['list'][i]['rak'] == getdata(r)['list'][i + 1]['rak']:
            if getdata(r)['list'][i]['created_at'] >= getdata(r)['list'][i + 1]['created_at']:
                j += 1
    j = j + 1
    return j


def createtimeSortWithTop(r):
    j, k = 0, 0
    for i in range(0, len(getdata(r)['list']) - 1):
        if getdata(r)['list'][i]['post_type'] == 1 and getdata(r)['list'][i]['is_top'] == -1:
            k += 1
            if getdata(r)['list'][i]['created_at'] >= getdata(r)['list'][i + 1]['created_at']:
                j += 1
    return j,k

def voteSortWithTop(r):
    j, k = 0, 0
    for i in range(0, len(getdata(r)['list']) - 1):
        if getdata(r)['list'][i]['post_type'] == 1 and getdata(r)['list'][i]['is_top'] == -1:
            k += 1
            if getdata(r)['list'][i]['vote_count'] >= getdata(r)['list'][i + 1]['vote_count']:
                j += 1
    return j,k

def commentSortWithTop(r):
    j, k = 0, 0
    for i in range(0, len(getdata(r)['list']) - 1):
        if getdata(r)['list'][i]['post_type'] == 1 and getdata(r)['list'][i]['is_top'] == -1:
            k += 1
            if getdata(r)['list'][i]['comment_count'] >= getdata(r)['list'][i + 1]['comment_count']:
                j += 1
    return j,k


def creatArticle(headers=None,user_id = None):
    now = time.strftime("%Y%m%d%H%M%S", time.localtime(time.time()))
    params = {'post_title': '测试发表文章' + now,
              'post_content': '这里是文章内容',
              'category_id': '1',
              'topics': 'test;测试'}
    r = ironhide().interfacetest('/api/website/articles/create', 'POST', params,headers,type='pc_web')
    articleId = getarticleId(user_id)
    return articleId

def getArticleShow_top(article_id,headers=None):
    params = {'post_id': article_id}
    r = ironhide().interfacetest('/api/website/articles/show', 'GET', params,headers,type='pc_web')
    is_top  = getdata(r)['is_top']
    return is_top


def articlesOnline(headers=None,user_id = None,type = 1):
    if type == 1:
        post_id = getarticleId(user_id, status=-1)
    else:
        post_id = getarticleId(user_id, status=1)
    params = {'post_id': post_id,
              'type': type,
              'reason': ''}
    r = ironhide().interfacetest('/api/admin/articles/online', 'POST', params,headers,type='admin')


def articleComment(article_id,headers=None):
    params = {'article_id': article_id, 'content': 'test'}
    r = ironhide().interfacetest('/api/mobile/v1/articles/comment', 'POST', params,headers)
    return r

def articleOff_articlesId(article_id,headers=None):
    params = {'post_id': article_id,
              'type': '-1',
              'reason': 'test'}
    r = ironhide().interfacetest('/api/admin/articles/online', 'POST', params,headers,type='admin')
    return r

def apply_step1(type,headers=None,organization_name='组织机构名称'+ time.strftime("%H%M%S", time.localtime(time.time())),organization_code='12345678-1'):
    if type == 1:
        params = {'type': '1',
                  'organization_name': '',
                  'organization_code': '',
                  'organization_pic': '',
                  'company_url': '',
                  'operator_name': '运营者姓名',
                  'operator_id_type': '1',
                  'operator_id': '431381198109106573',
                  'operator_pic': 'Foaif-rR8s9q3LHYxMtHhZqmmrDg',
                  'operator_email': 'songkui@istuary.com',
                  'operator_mobile': '18980709020',
                  'sms_code': '26o4',
                  'province_id': '20',
                  'city_id': '602'}
    elif type == 2:
        now_short = time.strftime("%H%M%S", time.localtime(time.time()))
        params = {'type': '2',
                  'organization_name': organization_name,
                  'organization_code': organization_code,
                  'organization_pic': 'Foaif-rR8s9q3LHYxMtHhZqmmrDg',
                  'company_url': 'http://www.baidu.com',
                  'operator_name': '运营者姓名',
                  'operator_id_type': '',
                  'operator_id': '',
                  'operator_pic': '',
                  'operator_email': 'songkui@istuary.com',
                  'operator_mobile': '18980709020',
                  'sms_code': '26o4',
                  'province_id': '20',
                  'city_id': '602'}
    r = ironhide().interfacetest('/api/website/users/apply_author_step_1', 'POST', params,headers,type='pc_web')
    return r

def apply_step2(user_id,headers=None):
    name = getUsernamebyUserid(user_id)
    params = {'name': name,
              'introduction': '安全号介绍',
              'avatar': 'FsZWl-TxJ2pHo3X0QP2MKnORG57l',
              'supplement': '安全号补充说明'}
    r = ironhide().interfacetest('/api/website/users/apply_author_step_2', 'POST', params,headers,type='pc_web')
    return r

def apply_verify(type,apply_id,headers=None):
    params = {'apply_id': apply_id,
              'status': type,
              'reason': '审核未通过'}
    r = ironhide().interfacetest('/api/admin/users/verify', 'POST', params,headers,type='admin')

def user_forbid(user_id,type = -1,headers=None):
    params = {'user_id': user_id, 'status': type}
    r = ironhide().interfacetest('/api/admin/users/forbid', 'POST', params,headers,type='admin')


def focus_topic(topic_id,headers=None):
    params = {'topic_id': topic_id}
    r = ironhide().interfacetest('/api/mobile/v1/topics/follow', 'POST', params, headers)


def favor_AQ(type=None,article_id=None,answer_id=None,headers=None):
    if type == 0:
        params = {'article_id': article_id}
        r = ironhide().interfacetest('/api/mobile/v1/articles/favor_article', 'POST', params, headers)
    elif type == 1:
        params = {'answer_id': answer_id}
        r = ironhide().interfacetest('/api/mobile/v1/answers/favor', 'POST', params, headers)
    return r

if __name__ == '__main__':
    test = ironhide()
    # params = {'mobile':'18980709020','password':'123456'}
    # test.gettoken(params)
    # print test.gettoken('18980709020','123456')
    # print getheaders('18980709020','123456')
    # print data[env]['server']['host']


