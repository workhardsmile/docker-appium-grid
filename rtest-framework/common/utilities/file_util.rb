require 'fileutils'
require "rexml/document"

include REXML
module Utilities
  module  FileUtil
    class << self
      def delete_files_in_folder!(folder_absolute_path)
        FileUtils.rm_r Dir.glob("#{folder_absolute_path}/*")
      end

      def wait_file_present(file_absolute_path, timeout=60)
        (timeout/5).times do
          if File.exist? file_absolute_path
            Common.logger_info "Utilities::FileUtil - wait file present in #{timeout} seconds - pass. [#{file_absolute_path}] exist."
            return true            
          end
          sleep 5
        end
        Common.logger_error "Utilities::FileUtil - wait file present in #{timeout} seconds - failed. [#{file_absolute_path}] is not found."
      end

      def get_base64_encoding_file_content (file_path)
        Base64.encode64(File.read(file_path)).gsub!("\n", '')
      end

      #description: Write xml data to file and format the data in xml format
      #parameters:
      #            file_name: name of file
      #            dir_name: the name of the directory where you are writing to
      #            data: xml response data
      #example: FileUtil.write_xml_file('act_2_swimmer_details.xml','data',xml_reponse)
      def write_xml_file(file_name, dir_name, data)

        #create formatter object
        formatter = REXML::Formatters::Pretty.new

        #compact set to true for using as little spaces as possible
        formatter.compact = true

        #remove existing file
        file_path = File.expand_path("../#{dir_name}", File.dirname(__FILE__))
        f = "#{file_path}/#{file_name}"
        if File.exist? f
          File.delete f
        end

        #write data to xml file in xml format
        begin
          file = File.open(f,"w+")
          formatter.write(data,file)
        rescue Errno::ENOENT => e
          Common.logger_error "#{self.class}.#{__method__} - Could not open file #{f} #{e.message}"
        rescue IOError => e
          Common.logger_error "#{self.class}.#{__method__} - Could not write to file #{f} #{e.message}"
        ensure
          file.close unless file == nil
        end
      end

      #description: Compare two files line by line simultaneously with the ability to skip desired lines by list of strings
      #parameters:
      #            exp: the expected file to compare
      #            act: the actual file to compare
      #            *args: list of strings used to omit lines that match (ie. skip to the next line when comparing lines from both files)
      #example: Utilities::FileUtil.compare_file_details("#{file_path}/exp_heatsheet.xml","#{file_path}/act_heatsheet.xml",'heatId','id','heatEntryId','swimmerId','meetId','roundId','teamId')
      def compare_file_details(exp,act,*args)

        #open and read both files
        exp_file = File.open(exp,"r")
        act_file = File.open(act,"r")

        #go through two files simultaneously line by line
        exp_file.each.zip(act_file.each).each do |line1, line2|

          #if files are xml files parse the nodes
          if(File.extname(File.basename(exp)).eql?('.xml'))

            #parse xml node name
            _line = line1.gsub(/\s+/," ")
            _line = _line.split("<",2).last
            _line = _line.split(">",2).first
          end

          #skip current line and go to next line if node name is found
          next if args.include?(_line)
          puts line1

          #compare current line from both files
          if !line1.eql?(line2)
            Common.logger_error "#{self.class}.#{__method__}: \n\nFile: #{File.basename(exp)}\nLine: #{line1}\n Doesn't Match \n\nFile: #{File.basename(act)}\nLine: #{line2}"
            return false
          end
        end
        true
      end

      #description: Compare two files if files are the same return true, otherwise return false
      #parameters:
      #            f1: file 1 to compare
      #            f2: file 2 to compare
      #example: FileUtil.compare_file_details("#{file_path}/exp_heatsheet.xml","#{file_path}/act_heatsheet.xml")
      def compare_files(f1,f2)

        #compare two files
        res = FileUtils.compare_file(f1,f2)
        if(!res)
          Common.logger_error "#{self.class}.#{__method__} - File #{f1} did not match File  #{f2}."
        end
        res
      end
    end
  end
end
