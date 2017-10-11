require 'logger'
require 'fileutils'

class LoggerS
  logfolder = File.absolute_path("#{File.dirname(__FILE__)}/../../output/log").gsub(File::SEPARATOR, File::ALT_SEPARATOR || File::SEPARATOR)
  #path = File.join(File.dirname(__FILE__),"../..","output","log")
  
  # New Line, creates subdirectories if needed
  FileUtils.mkdir_p logfolder if not File.exist? logfolder

  file_path = File.join(logfolder,"#{$logfile||'automation.log'}.txt")
  @@instance = Logger.new file_path
  @@instance.datetime_format = "[%Y-%m-%d %H:%M:%S]"
  @@instance.formatter = proc { |severity, datetime, progname, msg|
    "[#{datetime.to_s.gsub(' +0800','')}] #{severity}: #{msg}\n"
  }
  
  def self.instance    
    return @@instance
  end

  private_class_method :new
end

$logger = LoggerS.instance

