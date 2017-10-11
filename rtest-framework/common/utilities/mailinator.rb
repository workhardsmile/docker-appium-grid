require "rest-client" rescue false
require "json"

######################################################################
#normal: get_email_body_by_from_email_and_subject(from_email=nil,subject=nil,after_date="2015-01-01",include_content=nil,timeout_loop=12,loop_unit=5,format=:html)
#eg.
#mailinator = Utilities::Mailinator.new("active20151013190702@mailinator.com")
#
#content = mailinator.get_email_body_by_from_email_and_subject("noreply@awntx3.email.active.com","Incomplete registration on","2015-01-01")
#
# get body by include subject
# mailinator.get_email_body_by_subject("temp")
#
# get body by from
# mailinator.get_email_body_by_from("Jabco.Shen@activenetwork.com")
#
# get body by include subject and from
# mailinator.get_email_body_by_subject_and_from("temp","Jabco.Shen@activenetwork.com")
#
# check email exist in inbox by email subject
# mailinator.check_email_exist_by_subject("temp")
######################################################################
module Utilities
  class Mailinator
    HOME_URL="https://api.mailinator.com/api"
    @@stored_cookies = {"JSESSIONID"=>"69C3CD0586F1F8C4E3675E989EA6338C"}
    attr_reader :mail_messages, :hash_messages
    def initialize(email)
      @token = "b0b09aabeb7f450bb4f12c85c769866d"
      if email.include?("@") && (!email.include?("mailinator.com"))
        Common.logger_error "#{email} should include @mailinator.com"
      else
        @user_name = email.split("@")[0]
      end
      refresh_mail_messages
    end

    def refresh_mail_messages
      url = "#{HOME_URL}/inbox?to=#{@user_name}&token=#{@token}"
      result = self.class.http_get_by_url(url)
      messages = JSON.parse(result)["messages"]
      @mail_messages = messages.reverse.map{|messgae| MailMessage.new(messgae)}
      @hash_messages = @mail_messages.map{|message| message.to_hash unless message.nil?}
    end

    #:id,:seconds_ago,:to_email,:from_email,:from_name,:date_time,:date,:been_read,:from_ip,:subject
    def get_mail_mesasge_by_include_conditions(conditions={"subject"=>""})
      @hash_messages.each do |hash_message|
        flag = true
        # conditions.inject{|flag,condition| flag && hash_message[condition["property"].to_sym].include?(hash_message[condition["value"].to_sym]) }
        conditions.each do |key,value|
          if "#{key}".include?("date")
            flag = flag && (Date::DateTime.parse("#{hash_message[:date_time]}")>=Date::DateTime.parse("#{value}"))
          else
            flag = flag && "#{hash_message[key.to_sym]}".downcase.include?("#{value}".downcase)
          end
        end
        return MailMessage.new(hash_message) if flag
      end
      nil
    end

    def get_email_body_by_from_email_and_subject(from_email=nil,subject=nil,after_date="2015-01-01",include_content=nil,timeout_loop=12,loop_unit=5,format=:html)
      conditions = {"to_email"=>@user_name,"from_email"=>from_email,"subject"=>subject,"date"=>after_date}
      timeout_loop.times.each do |i|
        mail_message = get_mail_mesasge_by_include_conditions(conditions)
        if (!mail_message.nil?) && mail_message.body(format).include?("#{include_content}")
        return mail_message.body(format)
        else
          Common.logger_info "loop #{i} failed: #{self.class}.#{__method__}(#{conditions}) \n #{@hash_messages}"
        end
        sleep(loop_unit)
        refresh_mail_messages
      end
      Common.logger_error "Timeout error in loop #{timeout_loop}: #{self.class}.#{__method__}"
    end

    def check_email_exist_by_subject(include_subject)
      conditions = {"subject" => include_subject}
      mail_mesasge = get_mail_mesasge_by_include_conditions(conditions)
      unless mail_mesasge.nil?
        Common.logger_info "#{__method__}(#{include_subject}).passed"
      else
        Common.logger_error "#{__method__}(#{include_subject}).failed, inbox is:#{@hash_messages}"
      end
    end

    def get_email_body_by_subject(include_subject,format=:html)
      conditions = {"subject" => include_subject}
      mail_mesasge = get_mail_mesasge_by_include_conditions(conditions)
      return mail_mesasge.body(format) unless mail_mesasge.nil?
      nil
    end

    def get_email_body_by_from(from,format=:html)
      conditions = {"from_email" => from}
      mail_mesasge = get_mail_mesasge_by_include_conditions(conditions)
      return mail_mesasge.body(format) unless mail_mesasge.nil?
      nil
    end

    def get_email_body_by_subject_and_from(include_subject,from,format=:html)
      conditions = {"subject" => include_subject, "from_email" => from}
      mail_mesasge = get_mail_mesasge_by_include_conditions(conditions)
      return mail_mesasge.body(format) unless mail_mesasge.nil?
      nil
    end

    class MailMessage
      attr_reader :id,:seconds_ago,:to_email,:from_email,:from_name,:date_time,:date,:been_read,:from_ip,:subject
      def initialize(hash_message)
        return nil if hash_message.nil? || (hash_message["id"].nil? && hash_message[:id].nil?)
        @id = hash_message["id"] || hash_message[:id]
        @seconds_ago = hash_message["seconds_ago"] || hash_message[:seconds_ago]
        @to_email = hash_message["to"] || hash_message[:to_email]
        @from_email = hash_message["fromfull"] || hash_message[:from_email]
        @from_name = hash_message["from"] || hash_message[:from_name]
        @date_time = hash_message["time"].nil? ? hash_message[:date_time] : Time.at(hash_message["time"].to_s[0..-4].to_i)
        @date = @date_time.strftime("%Y-%m-%d")
        @been_read = ("#{hash_message["been_read"] || hash_message[:been_read]}"=="true") ? true : false
        @from_ip = hash_message["ip"] || hash_message[:from_ip]
        @subject = hash_message["subject"].nil? ? hash_message[:subject] : hash_message["subject"].gsub("=5F","_").gsub("=?UTF-8?Q?","").gsub("?=","")
        @body = hash_message["body"] || hash_message[:body]
      end

      def to_hash
        {:id=>@id,
          :seconds_ago=>@seconds_ago,
          :to_email=>@to_email,
          :from_email=>@from_email,
          :from_name=>@from_name,
          :date_time=>@date_time,
          :date=>@date,
          :been_read=>@been_read,
          :from_ip=>@from_ip,
          :subject=>@subject,
          :body=>@body}
      end

      def body(format=:html,timeout=30)
        return @body unless @body.nil?
        result = nil
        url = "#{HOME_URL}/email?id=#{@id}"
        (timeout/5).times.each do |i|
          result = Mailinator.http_get_by_url(url)
          hash_message = JSON.parse(result)
          if format.to_sym == :html
            @body = hash_message["data"]["parts"].last["body"]
          else
            @body = hash_message["data"]["parts"].first["body"]
          end
          break unless @body.nil?
          sleep(6)
         end
         Common.logger_info("#{self.class}:\n#{result}")
         @body
      end
    end

    def self.http_get_by_url(request_url,custom_parameters={},flag=true)
      #user_agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.155 Safari/537.36"
      #accept = "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8"
      response = nil
      begin
        Common.logger_info "get request by #{request_url}."
        response = RestClient.get request_url, {:cookies => @@stored_cookies}.merge(custom_parameters)
        @@stored_cookies["JSESSIONID"] = response.headers[:set_cookie][0].split("=")[1].split(";")[0] rescue @@stored_cookies["JSESSIONID"]
        Common.logger_info "get by #{request_url} successfully!"       
      rescue => e
        unless response.nil?
          Common.logger_info "#{response.code} #{response.headers}"    
        end
        Common.logger_info "ERROR in get response from url: -- #{request_url} \n #{e.message}"
        if "#{e.message}".include?("429") && flag
          sleep(90)
          response = http_get_by_url(request_url,{},false)
        end
      end
      response
    end
  end
end
