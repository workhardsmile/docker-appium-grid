#-*- coding:utf-8 -*-
import redis,yaml
from interface.testmain import *

data = yaml.load(file(os.path.dirname(__file__)+'/database.yml'))

# env = 'QA'
env = getenv()
test_redis = redis.Redis(host=data[env]['redis']['host'], port=data[env]['redis']['port'], db=data[env]['redis']['db'],password=data[env]['redis']['password'])


#删除注册、重置、修改密码相关redis
def reset_redis(mobile):
    test_redis.delete('sms:register:success_count:%s'%mobile)
    test_redis.delete('sms:forget_password:success_count:%s'%mobile)
    test_redis.delete('sms:update_password:success_count:%s'%mobile)
    test_redis.delete('sms:register:error_count:%s'%mobile)
    test_redis.delete('sms:forget_password:error_count:%s'%mobile)
    test_redis.delete('sms:update_password:error_count:%s'%mobile)
    test_redis.delete('sms:apply_author:success_count:%s'%mobile)


#注册验证码
def register_code(mobile):
    code = test_redis.get('sms:register:%s' % mobile)
    return code

#注册验证码有效期
def register_codetime(mobile):
    time = test_redis.ttl('sms:register:%s' % mobile)
    return time

#注册成功接收短信次数
def register_success(mobile):
    count = test_redis.get('sms:register:success_count:%s' % mobile)
    return count

#注册失败次数
def register_error(mobile):
    count = test_redis.get('sms:register:error_count:%s' % mobile)
    return count


#忘记密码验证码
def forget_code(mobile):
    code = test_redis.get('sms:forget_password:%s' % mobile)
    return code

#忘记密码验证码有效期
def forget_codetime(mobile):
    time = test_redis.ttl('sms:forget_password:%s' % mobile)
    return time

#忘记密码成功接收短信次数
def forget_success(mobile):
    count = test_redis.get('sms:forget_password:success_count:%s' % mobile)
    return count

#忘记密码失败次数
def forget_error(mobile):
    count = test_redis.get('sms:forget_password:error_count:%s' % mobile)
    return count

#修改密码验证码
def update_code(mobile):
    code = test_redis.get('sms:update_password:%s' % mobile)
    return code

#修改密码验证码有效期
def update_codetime(mobile):
    time = test_redis.ttl('sms:update_password:%s' % mobile)
    return time

#修改密码成功接收短信次数
def update_success(mobile):
    count = test_redis.get('sms:update_password:success_count:%s' % mobile)
    return count

#修改密码失败次数
def update_error(mobile):
    count = test_redis.get('sms:update_password:error_count:%s' % mobile)
    return count

#昵称修改时间
def username_data(userid):
    time = test_redis.ttl('user:update_username:%s' % userid)
    return time

#删除昵称修改限制时间
def username_del(userid):
    test_redis.delete('user:update_username:%s' % userid)

#昵称修改
def username_status(userid):
    time = test_redis.get('user:update_username:%s' % userid)
    return time

#申请安全号验证码
def apply_code(mobile):
    code = test_redis.get('sms:apply_author:%s' % mobile)
    return code

if __name__=='__main__':
    print register_codetime('13540108163')
    print register_success('13540108163')
    print register_error('13540108163')
    # print forget_code('18980709020')
    # print update_code('18980709020')
    # reset_redis('15982326275')
    # reset_redis('18980709020')