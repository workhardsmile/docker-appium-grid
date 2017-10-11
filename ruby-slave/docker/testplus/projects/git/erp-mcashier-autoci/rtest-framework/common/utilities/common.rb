require 'yaml'
require 'uuidtools'
require "time"
#require 'tzinfo'
require 'base64'
require "socket"
require 'fileutils'
require_relative '../logger/logger_instance.rb'

module Common
  class << self
    #get the local ip address
    def get_local_ip
      UDPSocket.open {|s| s.connect("www.bing.com", 1); s.addr.last}
    end

    def timestamp
      t = Time.now
      t.strftime("[%Y-%m-%d %H:%M:%S]")
    end

    def logger_error(message)
      puts "ERROR- #{message}"
      $result = "Failed"
      current_url = ($driver!=nil && ($driver.current_url.include?("http")) rescue false) ? "#{$driver.current_url}\n" : nil
      $logger.error "#{message}".gsub("\\n","\n")
      $errormessage = "#{$errormessage}" <<timestamp<<" -- #{current_url}#{message}\n"
      raise message
      false
    end

    def logger_step(message)
      puts message
      $logger.info "#{message}".gsub("\\n","\n")
    end

    def logger_info(message)
      puts "INFO - #{message}"
      $logger.info "#{message}".gsub("\\n","\n")
    end

    def upcase_first_letter(string)
      string[0] = string[0].capitalize
      return string
    end

    def compare_strings (string_1, string_2)
      if string_1.eql? string_2
        Common.logger_info "compare_strings - the 2 strings match. string 1:#{string_1} matches string 2:#{string_2}"
      else
        Common.logger_error "compare_strings - the 2 strings do not match. string 1:#{string_1} does not match string 2:#{string_2}"
      end
    end
    
    def string_match_substring_with_regexp(full_string,substring)
      sub_regexp = nil
      if substring.class != Regexp
        sub_regexp = /#{Regexp.quote(substring)}/
      else
        sub_regexp = substring
      end
      mt = sub_regexp.match("#{full_string}")
      return mt[0] if mt!=nil
      nil
    end

    def string_contains_substring (string_1, string_2)
      if string_1.include? string_2
        Common.logger_info "#{string_2} is a substring of #{string_1}"
      else
        Common.logger_error "#{string_2} is a not substring of #{string_1}"
      end
    end

    def kill_windows_process_by_name(process_name)
      $current_platform ||= Utilities::OS.get_current_os
      if $current_platform == :windows
        system "taskkill /im #{process_name} /f /t >nul 2>&1"
      else
        Common.logger_info "It's not supported for platform #{$current_platform}"
      end
    end

    def restore_hosts_file
      if $OS == :windows
        host_file = "C:/Windows/System32/drivers/etc/hosts"
        bak_file = "C:/Windows/System32/drivers/etc/hosts.bak"
        FileUtils.cp(bak_file,host_file)
        Common.logger_info "restore hosts file from backup - success."
      else
        Common.logger_info "restore hosts file from backup - warnning. unable to restore hosts file in other OS than windows"
      end
    end

    def update_hosts_file
      if $OS == :windows
        project_host_file = "#{File.dirname(__FILE__)}/../../data/hosts"
        host_file = "C:/Windows/System32/drivers/etc/hosts"
        bak_file = "C:/Windows/System32/drivers/etc/hosts.bak"
        FileUtils.cp(host_file,bak_file)
        FileUtils.cp(project_host_file,host_file)
        Common.logger_info "replace hosts file to project specified one - success."
      else
        Common.logger_info "replace hosts file to project specified one - warnning. unable to update hosts file in other OS than windows"
      end
    end
    
    # Common.get_usd_format_str_by_number(1234567.1) => "1,234,567.10"
    def get_usd_format_str_by_number(number)
      amount_arry = format("%.2f",number).split(".")
      nil while amount_arry[0].gsub!(/(.*\d)(\d\d\d)/, '\1,\2')
      return "#{amount_arry[0]}.#{amount_arry[1]}"
    end
    
  end
end