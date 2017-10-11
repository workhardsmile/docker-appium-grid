# -*- coding:utf-8 -*-
import unittest
from interface.testbasic import *
from interface import myunittest


def test(params,headers=None):
    r = ironhide().interfacetest('/api/mobile/v1/settings/about_us', 'GET', params,headers)
    return r

class test_settings_about_us(myunittest.TestCase):
    # 关于我们
    def test_1(self):
        u"""未登录获取关于我们"""
        self.case_id = 'test_1'
        params = {}
        r = test(params)
        print r.content
        self.assertEqual(getcode(r), 1)
        resdata = {"content":"关于我们\n\n国内首家专注报道物联网安全领域的新媒体，致力于打造该领域最具价值的情报站和智库，建设物联网安全爱好者们交流、分享技术的新型社群。\n物联网安全核心团队主要成员来自绿盟科技、华为、阿里巴巴、物联网安全协会、百度、赛门铁克等国内外信息安全一流的企业单位。\n我们筛选最有价值的信息，你能在这里看到全球最有想法、最值得关注的物联网安全动态和爆料，最具风向标的标杆企业和预研项目，最有料的业界大牛和展会，以及它们背后的故事。\n物联网技术层面，我们的研究从以云计算为代表的应用层，到以互联网为成熟标志的网络层，再到以二维码为最佳范例的感知层。\n追踪物联网覆盖和影响的行业，尤其是有大规模商机和市场的智慧城市，智慧能源，自动驾驶，智慧农业等工农业领域，再到和消费者息息相关的智能穿戴，智能家居，智能玩具，生命健康等。\n\n\n我们欢迎这样的人\n\n有一定的网络安全基础\n信息安全从业者或热衷于信息安全的在校学生\n对信息安全有着不可磨灭的热情的自由职业者\n乐于分享，拒绝娱乐。有着真正的Hack精神\n\n\n加入我们你可以获得\n\n团队成员之间的经验分享\n学习安全技术的机会\n职业发展\n拥有一群志同道合的朋友\n在日后工作中可多出一份项目经验\n获得许多团队的内部资料及内部福利\n只为寻找志同道合的小伙伴，希望小伙伴是带着真心与激情来的\n\n\n联系方式：\n\n电话: 028-61592131\n官方QQ群: 578328743\n邮箱: hezuo@wulianaq.com\n"}
        self.assertEqual(json.dumps(getdata(r)), json.dumps(resdata))

    def test_2(self):
        u"""登录获取关于我们"""
        self.case_id = 'test_2'
        params = {}
        r = test(params,headers=self.headers)
        print r.content
        self.assertEqual(getcode(r), 1)
        resdata = {"content":"关于我们\n\n国内首家专注报道物联网安全领域的新媒体，致力于打造该领域最具价值的情报站和智库，建设物联网安全爱好者们交流、分享技术的新型社群。\n物联网安全核心团队主要成员来自绿盟科技、华为、阿里巴巴、物联网安全协会、百度、赛门铁克等国内外信息安全一流的企业单位。\n我们筛选最有价值的信息，你能在这里看到全球最有想法、最值得关注的物联网安全动态和爆料，最具风向标的标杆企业和预研项目，最有料的业界大牛和展会，以及它们背后的故事。\n物联网技术层面，我们的研究从以云计算为代表的应用层，到以互联网为成熟标志的网络层，再到以二维码为最佳范例的感知层。\n追踪物联网覆盖和影响的行业，尤其是有大规模商机和市场的智慧城市，智慧能源，自动驾驶，智慧农业等工农业领域，再到和消费者息息相关的智能穿戴，智能家居，智能玩具，生命健康等。\n\n\n我们欢迎这样的人\n\n有一定的网络安全基础\n信息安全从业者或热衷于信息安全的在校学生\n对信息安全有着不可磨灭的热情的自由职业者\n乐于分享，拒绝娱乐。有着真正的Hack精神\n\n\n加入我们你可以获得\n\n团队成员之间的经验分享\n学习安全技术的机会\n职业发展\n拥有一群志同道合的朋友\n在日后工作中可多出一份项目经验\n获得许多团队的内部资料及内部福利\n只为寻找志同道合的小伙伴，希望小伙伴是带着真心与激情来的\n\n\n联系方式：\n\n电话: 028-61592131\n官方QQ群: 578328743\n邮箱: hezuo@wulianaq.com\n"}
        self.assertEqual(json.dumps(getdata(r)), json.dumps(resdata))


if __name__ == '__main__':
    unittest.main()
