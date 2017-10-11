# encoding: UTF-8
require "net/http"
require "uri"
require 'rexml/document'
require "find"
require "yaml"
require 'json'
require 'rest_client'

include REXML
class ImportAutoScript
  attr_accessor :url, :config
  def initialize
    @config = YAML.load(File.open("#{File.dirname(__FILE__)}/project_config.yml"))
    #@url ="http://www.testplus.com/import_data/import_automation_script"
    @url = "http://10.4.237.142:8000/import_data/import_script_without_test_plan"
    @auto_case_array = []
  end

  def update_testlink
    begin
      data = {"case_arrays" => @auto_case_array}
      RestClient.post("http://10.4.237.142:8002/testlink/update_status", data.to_json,{"Content-Type" => "application/json"})
    rescue Exception => e
      puts "failed to update status to teslink, #{@auto_case_array}"
    end
  end
  
  def update_script_testlink(script_name,case_array)
    begin
      data = {"script_name"=>script_name,"test_cases" => case_array}
      RestClient.post("http://10.4.237.142:8002/testlink/update_automation_test_name", data.to_json, {"Content-Type" => "application/json"})
    rescue Exception => e
      puts "failed to update script to teslink, #{@auto_case_array}"
    end
  end

  def create_xml (strScriptName,strPlanName,strStatus,strComment,strOwner,intTime,strProject,strDriver,strTags,arrayCaseID)
    doc = REXML::Document.new
    data = doc.add_element("data")
    auto_script = data.add_element("automation_script")
    script_name = auto_script.add_element("name")  #add_element("script_name")
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
      case_id = auto_cases.add_element("case_info")  #case_id = auto_cases.add_element("case_id")
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

  def parese_code(strProject,strDriver,strPath,strPrefix)
    Dir.glob("#{File.dirname(__FILE__)}/../#{strPath}/*").each do |folder|
      if File.directory?(folder)
        if File.exist? "#{folder}/config.yml"
          puts ">>>>>> parse for script -- #{folder}"
          as = Hash.new
          as["script_name"] = File.basename(folder).gsub(".rb","")
          as["case_info"] = Array.new  #as["case_id"] = Array.new
          # get script information from the config.yml
          begin
            config = YAML.load(File.open("#{folder}/config.yml"))
            if config and is_script_status_valid?(formart_status(config["status"]))
              as["plan_name"]= as["script_name"] #config["plan_name"]
              as["timeout_limit"]= config["timeout"]
              as["owner"]= config["owner"]
              as["status"]= formart_status(config["status"])
              as['comment'] = config['comment']
              as['tags']= config['keywords']
              # get the script name and case ids from script files
              next unless as["status"].downcase == "completed"
              Dir.glob("#{folder}/*.rb").each do |file_path|

                File.open(file_path, "r") do |file|
                  file.each_line  do |line|
                    if /^\s*it ".*do/.match(line)
                        case_id = line.split('"')[1].split('_')[0]
                        case_comments = line.split('"')[1].split('_')[1]
                        if not case_id.nil?
                          if case_id.include? strPrefix
                            as["case_info"].push "#{case_id}###{case_comments}"  #as["case_id"].push case_id
                          end
                        end
                      end
                    end
                  end
                
              end
              puts as
              puts "as status: #{as["status"]}"
              if as["case_info"].size > 0   #as["case_id"].size > 0
                xml = create_xml(as["script_name"],as["plan_name"],as["status"],as['comment'],as["owner"],as["timeout_limit"],strProject,strDriver,as["tags"],as["case_info"])
                post @url,xml.to_s
                #update_script_testlink("#{strPath}/#{as["script_name"]}",as["case_id"])
                # if as['status'] == 'Completed'
                #   @auto_case_array += as["case_id"]
                # end
              end
            else
              puts "#{as['script_name']} has wrong config.yml"
            end
          rescue => e
            puts "#####\n####EXCEPTION: #{e}"
          end
        end
      end
    end
  end
  private
  def is_script_status_valid?(status)
    ['Completed', 'Work In Progress', 'Disabled', 'Known Bug', 'Test Data Issue'].include? status
  end

  def formart_status(status)
    "#{status.split(' ').map{|t| t.capitalize}.join(' ')}"
  end
end

import_data =  ImportAutoScript.new
config = import_data.config
project = ARGV[0].nil? ? 'demo' : ARGV[0]
if project
  unless config["#{project}"].nil?
    config["#{project}"].each do |c|
      import_data.parese_code c['marquee_name'], c['config_name'], c['path'], c['id_prefix']
      #import_data.update_testlink
    end
  else
    puts "the project <#{project}> you entered is wrong"
  end
else
  puts "you must specify the project"
end
