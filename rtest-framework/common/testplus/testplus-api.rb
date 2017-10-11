require "net/http"
require "uri"
require "rexml/document"
require 'rest_client'

include REXML
#SCREEN_SHORT_FOLDER = Dir.exist?("c:/marquee/screen_shots") ? "c:/marquee/screen_shots" : "#{File.dirname(__FILE__)}/../../output/screenshots"
SCREEN_SHORT_FOLDER = File.absolute_path("#{File.dirname(__FILE__)}/../../output/screenshots").gsub(File::SEPARATOR, File::ALT_SEPARATOR || File::SEPARATOR)
#LOG_FOLDER = File.absolute_path("#{File.dirname(__FILE__)}/../../output/test_results").gsub(File::SEPARATOR, File::ALT_SEPARATOR || File::SEPARATOR)
LOG_FOLDER = File.absolute_path("#{File.dirname(__FILE__)}/../../output/log").gsub(File::SEPARATOR, File::ALT_SEPARATOR || File::SEPARATOR)

module TESTPLUS
  def self.post url_string, xml_string
    uri = URI.parse url_string
    request = Net::HTTP::Post.new uri.path
    request.body = xml_string
    request.content_type = 'text/xml'
    response = Net::HTTP.new(uri.host, uri.port).start { |http| http.request request }
  end

  def self.post_case_result(case_result)
    # just forward to webserver in order to calculate the results
    data = {
      :protocol => {
        :what => 'Case',
        :round_id => case_result["round_id"],
        :data => {
          :script_name => case_result["script_name"],
          :case_id => case_result["case_id"],
          :result => case_result["status"],
          :error => case_result["description"],
          :screen_shot => case_result["screen_shot"],
          :server_log => case_result["server_log"]
        }
      }
    }
    #puts case_result.to_json
    Common.logger_info "Post case result to TEST-PLUS..."
    RestClient.post "#{$testplus_config["web_server"]}/status/update", data rescue false
    begin  
      case_result["screen_shot"].split(";").each do |screen_file|
        if "#{screen_file}".strip != ""
          RestClient.post "#{$testplus_config["web_server"]}/screen_shots",{"screen_shot"=> File.new(File.join(SCREEN_SHORT_FOLDER,screen_file),'rb')}
          FileUtils.remove_file File.join(SCREEN_SHORT_FOLDER,screen_file),true
        end
      end
    rescue => e
      Common.logger_error "post screen_shots #{case_result["screen_shot"]} to web server failed: #{e}"
    end
  end

  def self.post_script_status(script_result)
    # first, we update slave and assignment status
    # here, we only manage the slave and assignments status, and just forward the parameters to webserver in order to calculate the results
    script_status = script_result["status"].downcase == 'end' ? 'done' : 'failed'
    data = {
      :protocol => {
        :what => 'Script',
        :round_id => script_result["round_id"],
        :data => {
          :script_name => script_result["script_name"],
          :state => script_status,
          'service' => script_result["versions"].split('|').map do |s|
              temp = s.split("#")
              result = { "name"=>temp[0],"version"=>temp[1] }
            end
        }
      }
    }
    #puts script_result.to_json
    Common.logger_info "update script status: #{data}"
    (RestClient.post "#{$testplus_config["web_server"]}/status/update", data) rescue false
    return if $logfile.nil?
    log_params = JSON.parse($logjson)
    log_params["log"]["file_name"] = $logfile + ".txt"
    (RestClient.post "#{$testplus_config["web_logserver"]}/logs", log_params) rescue false   
    begin
      RestClient.post "#{$testplus_config["web_logserver"]}/upload", {"test_log" => File.new(File.join(LOG_FOLDER, log_params["log"]["file_name"]),'rb')}
    rescue => e
      Common.logger_error "post log file #{File.join(LOG_FOLDER, $logfile)} to web server failed: #{e}"
    end       
  end

  def self.update_script_state(id,name,tp_state,service_info)
    if id != "DEBUG"
      tp_description = tp_state
      if tp_state.downcase == 'end'
        tp_state = 'done'
      else
        tp_state = 'failed'
      end
      doc = REXML::Document.new
      protocol = doc.add_element("protocol")
      what = protocol.add_element("what")
      what.add_text "Script"
      round_id = protocol.add_element("round_id")
      round_id.add_text id.to_s
      data = protocol.add_element("data")
      script_name = data.add_element("script_name")
      script_name.add_text name.to_s
      state = data.add_element("state")
      state.add_text tp_state
      desc = data.add_element('description')
      desc.add_text tp_description
      if service_info != nil
        service = data.add_element('service')
      service.add_text service_info
      end
      if ENV['ResultPath'] != nil
        file_name = "#{ENV['ResultPath']}/sr_#{id}_#{Time.now.strftime("%Y%m%d%H%M%S")}_#{name}.xml"
        save_file_to_path(file_name,doc.to_s)
        Common.logger_info "write script state for [#{name}] to >> #{file_name}"
      end
    end
  end

  def self.update_case_result(id,name,case_number_string,tc_result,tc_error,tc_screen_shot,tc_error_log)
    if id != "DEBUG"
      case_number_string.split('||').each do |case_number|
        doc = REXML::Document.new
        protocol = doc.add_element("protocol")
        what = protocol.add_element("what")
        what.add_text "Case"
        round_id = protocol.add_element("round_id")
        round_id.add_text id
        data = protocol.add_element("data")
        script_name = data.add_element("script_name")
        script_name.add_text name
        case_id = data.add_element("case_id")
        case_id.add_text case_number
        test_result = data.add_element("result")
        test_result.add_text tc_result
        error = data.add_element("error")
        error.add_text tc_error.to_s
        screen_shot = data.add_element("screen_shot")
        screen_shot.add_text tc_screen_shot
        server_log = data.add_element("server_log")
        server_log.add_text tc_error_log.to_s
        #post $url_string, doc.to_s
        if ENV['ResultPath'] != nil
          file_name = "#{ENV['ResultPath']}/cr_#{id}_#{Time.now.strftime("%Y%m%d%H%M%S")}_#{case_number.gsub(/[^a-zA-Z 0-9]/, '')}.xml"
          save_file_to_path(file_name,doc.to_s)
          Common.logger_info "[#{case_number}] - [#{tc_result}], write result to >> #{file_name}"
          if tc_result != "Passed"
            Common.logger_info '##################################################################'
            Common.logger_info tc_error
            Common.logger_info '##################################################################'
          end
        end
      end
    end
  end

  def self.save_file_to_path(file_path,xml_string)
    aFile = File.new(file_path, "w")
    aFile.write(xml_string)
    aFile.close
  end

  def self.get_service_info(service_name,environment)

    if $round_id != "DEBUG"
      case environment.upcase
      when "INT"
        env = "INT"
      when "QA"
        env = "QA"
      when "REG"
        env = "REG"
      when "STG"
        env = "STG"
      when "PROD"
        env = "PROD"
      when "PINT"
        env = "PINT"
      else
      Common.logger_info "failed to get service info, #{environment} is not supported"
      return
      end
      begin
        @result =""
        data = "env1=#{env}&env2=#{env}"
        my_connection = Net::HTTP.new('arm-01w.dev.activenetwork.com',8080)
        response = my_connection.post('/ActiveDeploy/CompareHandle', data)
        temp = response.body.split("</a><p>")
        service_name.split('##').each do |s|
          temp.each do |t|
            if (/.*#{s}.*/).match t
              @result += "#{s}"+'#'+"#{t.split("to").last.gsub(" ","")}"+'|'
            end
          end
        end
        @result.chop
      rescue Exception => e
        Common.logger_info "#{e}"
        "failed to get service info, check log for more info"
      end

    end
  end
end
