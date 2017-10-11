# encoding: UTF-8
require "net/http"
require "uri"
require 'rexml/document'
require "find"
require "yaml"

include REXML
class ImportAutoScript
  attr_accessor :url, :config
  def initialize
    @url ="http://10.4.237.142:8000/import_data/import_script_without_test_plan"
  end

  def create_xml (strScriptName,strPlanName,strStatus,strComment,strOwner,intTime,strProject,strDriver,strTags,arrayCaseID)
    doc = REXML::Document.new
    data = doc.add_element("data")
    auto_script = data.add_element("automation_script")
    script_name = auto_script.add_element("name")
    script_name.add_text strScriptName
    tp_name = auto_script.add_element("plan_name")
    tp_name.add_text strPlanName
    status = auto_script.add_element("status")
    status.add_text strStatus
    comment = auto_script.add_element('comment')
    comment.add_text strComment
    owner = auto_script.add_element("owner")
    owner.add_text strOwner
    timeout = auto_script.add_element("timeout")
    timeout.add_text intTime.to_s
    project = auto_script.add_element("project")
    project.add_text strProject
    driver = auto_script.add_element("auto_driver")
    driver.add_text strDriver
    tags = auto_script.add_element("tags")
    tags.add_text strTags
    auto_cases = data.add_element("automation_cases")
    arrayCaseID.each do |tc|
      case_id = auto_cases.add_element("case_info")
      case_id.add_text tc
    end
    doc.to_s
  end

  def post url_string, xml_string
    uri = URI.parse url_string
    request = Net::HTTP::Post.new uri.path
    request.body = xml_string
    request.content_type = 'text/xml'
    response = Net::HTTP.new(uri.host, uri.port).start { |http| http.request request }
  end

  def parese_code(strProject,strDriver,strPrefix)
    Dir.glob("#{File.dirname(__FILE__).split('testplus')[0]}/interface/*/*.py").each do |test_file|
      if File.exist? "#{test_file}"
        puts ">>>>>> parse for script -- #{test_file}"
        as = Hash.new
        as["script_name"] = "#{File.basename(File.dirname(test_file))}-#{File.basename(test_file).gsub(".py","")}"
        as["case_info"] = Array.new
        as["plan_name"] = as["script_name"]
        as["timeout_limit"] = 1200
        as["status"] = 'Completed'
        as["owner"] = 'wugang05@meituan.com'
        as['comment'] = ''
        as['tags'] = 'interface'
        # get the script name and case ids from script files

        lines = IO.readlines(test_file)
        lines.each_with_index  do |line,index|
          if /^\s+def\s+(test\_.+)\(.*/.match(line)
            case_id = line.split('def')[1].split("(")[0].strip!
            comment = (lines[index+1].split('"""')[1] rescue "")
            as["case_info"].push "#{case_id}###{comment}" if "#{case_id}".include? strPrefix
          elsif (!as["owner"].include?("@")) && /^.+owner:\s+(.+\@.+)\(.*/.match(line.downcase)
            as["owner"] = line.downcase.split("owner:")[1].strip!
          end
        end
        if as["case_info"].size > 0
          puts as
          xml = create_xml(as['script_name'],as["plan_name"],as["status"],as["comment"],as["owner"],as["timeout_limit"],strProject,strDriver,as["tags"],as["case_info"])
          post @url,xml.to_s
        end
      end
    end
  end
end

import_data =  ImportAutoScript.new
import_data.parese_code('Demo','demo_pyunit_interfaces','test')
