require 'rbconfig'
# include Config

module Utilities
  module OS
    class << self
      # get system os
      def get_current_os
        @os ||= (
          host_os = RbConfig::CONFIG['host_os']
          case host_os
          when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
            :windows
          when /darwin|mac os/
            :macosx
          when /linux/
            :linux
          when /solaris|bsd/
            :unix
          else
            raise Error::WebDriverError, "unknown os: #{host_os.inspect}"
          end
        )
      end
    end
  end
end

$OS = Utilities::OS.get_current_os

