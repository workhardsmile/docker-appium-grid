# encoding: UTF-8
require 'yaml'
require "uri"
require "rest-client"
require "json"
require 'addressable/uri'
# require 'net/http'

class HttpTestlinkBase
  SERVICE_API_URL=YAML.load(File.open("#{File.dirname(__FILE__)}/../../../data/webserver_url.yml"))

  def self.url_query_string(hash={}, is_url=true)
    if hash.instance_of? String
      URI.encode hash
    elsif is_url
      uri = Addressable::URI.new
      uri.query_values = hash
      uri.query
    else
      query_str = ""
      hash.reject { |key, value| query_str="#{query_str}&#{key}=#{value}" }
      query_str[1, query_str.length-1]
    end
  end

  def self.http_request(method, url, data={}, header={}, timeout=300)
    response = nil
    url = "#{url}?#{url_query_string(data)}" if "#{method}".downcase == "get" && data.class == Hash
    Common.logger_info "[#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}]====>#{url} #{method} data: \n#{data}"
    begin     
      response = RestClient::Request.execute(method: "#{method}".downcase.to_sym, url: url, payload: data, timeout: timeout, headers: header)
    rescue => e
      response = e.response rescue e
    end
    Common.logger_info "[#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}]====>#{url} #{method} done."
    response
  end

  def self.get_testlink_cookies(data={})
    default_data = {"tl_login" => "testlink", "tl_password" => "123456"}
    request_url = "#{SERVICE_API_URL[$env]["TestLink"]}/login.php"
    response = http_request("post", request_url, default_data.merge(data))
    #puts response.headers[:token]
    return response.cookies
  end

  def initialize
    @headers = {:accept => "application/json, text/plain, */*; q=0.01",
                :content_type => "application/x-www-form-urlencoded",
                :cache_control => "no-cache",
                :user_agent => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36",
    }
    @testlink_cookies = nil
  end
  
  def testlink_request_unsign(method, api_name, data={}, header={})
    response = self.class.http_request(method, "#{SERVICE_API_URL[$env]["TestLink"]}#{api_name}", data, @headers.merge(header))
    return (JSON.parse(response) rescue "#{response}"), response
  end

  def testlink_request(method, api_name, data={}, header={})
    @testlink_cookies = self.class.get_testlink_cookies if @testlink_cookies.nil?
    testlink_request_unsign(method, api_name, data, @headers.merge({"Cookie" => @testlink_cookies}).merge(header))
  end

  def testlink_json_request(method, api_name, data={}, header={})
    testlink_request(method, api_name, data.to_json, @headers.merge({:content_type => "application/json"}).merge(header))
  end
  
  def testlink_form_request(method, api_name, data={}, header={})
    data[:multipart] = true
    testlink_request(method, api_name, data, @headers.merge(header))
  end
end

module RestClient
  module Payload
    class Multipart < Base
      def create_regular_field(s, k, v)
        s.write("Content-Disposition: form-data; name=\"#{k}\"".gsub("[]",""))
        s.write(EOL)
        s.write(EOL)
        s.write(v)
      end

      def create_file_field(s, k, v)
        begin
          s.write("Content-Disposition: form-data;")
          s.write(" name=\"#{k}\";".gsub("[]","")) unless (k.nil? || k=='')
          s.write(" filename=\"#{v.respond_to?(:original_filename) ? v.original_filename : File.basename(v.path)}\"#{EOL}")
          s.write("Content-Type: #{v.respond_to?(:content_type) ? v.content_type : mime_for(v.path)}#{EOL}")
          s.write(EOL)
          while data = v.read(8124)
            s.write(data)
          end
        ensure
          v.close if v.respond_to?(:close)
        end
      end
    end
  end
end
