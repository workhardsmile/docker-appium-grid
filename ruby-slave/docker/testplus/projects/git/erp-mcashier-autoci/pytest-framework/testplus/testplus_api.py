import requests,os,urllib2
from poster.encode import multipart_encode  
from poster.streaminghttp import register_openers
import json,time
import logging

class TestPlusAPI(object):
    def __init__(self):
        self.web_server = 'http://10.4.237.142:8000'
        self.web_logserver = 'http://10.4.237.142:8001'
        self.screen_folder = '../output/screenshots/'
        # self.log_folder = '../output/test_results/'
        self.log_folder = os.path.dirname(__file__) + '/../output/test_results/'
        self.headers = {'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
                'Connection': 'Keep-Alive'} 
        
    def set_versions(self, version_str):
        temp = version_str.split("#")
        result = {"name": temp[0], "version": temp[1] } if len(temp) > 1 else {}
        return result
        
    def upload_file(self,url,**file):
        register_openers()
        print file
        datagen, headers = multipart_encode(file)
        request = urllib2.Request(url, datagen, headers)  
        print urllib2.urlopen(request).read()      
    
    #@after(:each)   
    def post_case_result(self, case_result):
        # case_result = {"round_id":"48605", 
        # "case_id":"IH488", 
        # "status":"Failed", 
        # "description":"[2016-09-17 18:39:21] -- ERROR Testn -- ERROR Testn26----->     $logger.error messagen27----->      endn/Users/frankwu/Documents/workspace/ironhide-rubytest/common/utilities/common.rb:28:in 'logger_error'", 
        # "script_name":"articles_comment", 
        # "screen_shot":"20160824-18-00-46-524093000.png;", 
        # "server_log":""}
        if case_result["description"] != None:
            errortime = '['+ time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())+']'
            error = errortime + errortime + case_result["description"]
        else:
            error = ''
        params = { 
          "protocol" : { 
            "what" : 'Case', 
            "round_id" : case_result["round_id"], 
            "data" : { 
              "script_name" : case_result["script_name"], 
              "case_id" : case_result["case_id"], 
              "result" : case_result["status"], 
              # "error" : case_result["description"],
              # "error" : errortime + case_result["description"],
              "error" : error,
              "screen_shot" : case_result["screen_shot"],
              "server_log" : case_result["server_log"] 
            }}}
        logging.info(params)
        s = requests.session()
        r = s.post(self.web_server + "/status/update", json = params)
        for screen_file in case_result["screen_shot"].split(";"):
            if os.path.exists(self.screen_folder + screen_file) and self.screen_folder + screen_file != self.screen_folder:
                file = None
                try:
                    file = open(self.screen_folder+screen_file,'rb')
                    self.upload_file(self.web_server + "/screen_shots", **{"screen_shot" : file})                    
                    file.close()
                    os.remove(self.screen_folder+screen_file)
                except Exception,e:
                    print(self.screen_folder + screen_file, self.web_server + "/screen_shots", e) 
                    if file != None:
                        file.close()    
    
    #@after(:all)
    def post_script_status(self, script_result, log_json):
        # script_result = {"round_id":"48605", 
        # "script_name":"articles_comment", 
        # "status":"end", 
        # "versions":"IronhideWeb#1.1.0|IronhideAndroid#1.1.0|IronhideIos#1.1.0"}
        # log_json = {"log":{ 
        # "browser":"firefox", 
        # "date_time":"2016-09-17 21:12:38", 
        # "env":"QA", 
        # "round_id":48605, 
        # "script_name":"articles_comment", 
        # "script_path":"git/ironhide-rubytest/testing/interfaces", 
        # "file_name":"articles_comment-48605-20160917211238.htm"}, 
        # "commit":"Create Log"} 
        script_status = 'done' if script_result["status"].lower() == 'end' else 'failed'
        params = { 
          "protocol" : { 
            "what" : 'Script', 
            "round_id" : script_result["round_id"], 
            "data" : { 
              "script_name" : script_result["script_name"], 
              "state" : script_status, 
              "service" : map(self.set_versions, script_result["versions"].split("|"))
            }}}
        logging.info(params)
        s = requests.session()
        r = s.post(self.web_server + "/status/update", json = params)
        # print self.log_folder+log_json["log"]["file_name"]
        # print type(log_json)
        # print json.loads(log_json).get('log').get('file_name')
        log_json["log"]["file_name"] = log_json["log"]["file_name"] + '.txt'
        if os.path.exists(self.log_folder+log_json["log"]["file_name"]):
            r = s.post(self.web_logserver + "/logs", json = log_json)  
            file = None 
            try:
                file = open(self.log_folder+log_json["log"]["file_name"], 'rb')
                self.upload_file(self.web_logserver + "/upload", **{"test_log": file})
                file.close()
                #os.remove(self.log_folder+log_json["log"]["file_name"])
            except Exception,e:
                print(self.log_folder+log_json["log"]["file_name"], self.web_logserver + "/upload", e)
                if file != None:
                    file.close()

# if __name__ == '__main__':
#     test = TestPlusAPI()
#     print test.log_folder
#     # script_result = {"round_id":"48605",
#     #         "script_name":"articles_comment",
#     #         "status":"end",
#     #         "versions":"IronhideWeb#1.1.0|IronhideAndroid#1.1.0"}
#     # log_json = {"log":{
#     #         "browser":"firefox",
#     #         "date_time":"2016-09-17 21:12:38",
#     #         "env":"QA",
#     #         "round_id":48605,
#     #         "script_name":"articles_comment",
#     #         "script_path":"git/ironhide-rubytest/testing/interfaces",
#     #         "file_name":"articles_comment-48605-20160917211238.htm"},
#     #         "commit":"Create Log"}
#     # case_result = {"round_id":"48605",
#     #         "case_id":"IH488",
#     #         "status":"Failed",
#     #         "description":"[2016-09-17 18:39:21] -- ERROR Testn -- ERROR Testn26----->     $logger.error messagen27----->      endn/Users/frankwu/Documents/workspace/ironhide-rubytest/common/utilities/common.rb:28:in 'logger_error'",
#     #         "script_name":"articles_comment",
#     #         "screen_shot":"20160824-16-14-58-45905000.png;20160824-16-14-18-358735000.png;",
#     #         "server_log":""}
#
    # scriptresult = {"round_id": "48607",
    #                 "script_name": "about_us.py",
    #                 "status": "end",
    #                 "versions": "IronhideWeb#1.1.0|IronhideAndroid#1.1.0"}
    # caseresutlt = {"round_id": "48607",
    #                "case_id": "test_1",
    #                "status": "Failed",
    #                "description": "[2016-09-17 18:39:21] -- ERROR Testn -- ERROR Testn26----->     $logger.error messagen27----->      endn/Users/frankwu/Documents/workspace/ironhide-rubytest/common/utilities/common.rb:28:in 'logger_error'",
    #                "script_name": "articles_comment",
    #                "screen_shot": "20160824-16-14-58-45905000.png;20160824-16-14-18-358735000.png;",
    #                "server_log": ""}
    # log_json = {"log":{"browser":"iphone","date_time":"2016-09-19 12:48:29","env":"QA","round_id":48607,"script_name":"about_us.py","script_path":"git/ironhide-test/interface","file_name":"about_us.py-48607-20160919124829.htm"},"commit":"Create Log"}
    # test_plus = TestPlusAPI()
    # test_plus.post_case_result(case_result)
    # test_plus.post_script_status(script_result,log_json)
