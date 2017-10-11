require "rspec"
require "rspec/core/formatters/helpers"

class SnippetExtractor
  class NullConverter
    def convert(code)
      %Q(#{code}\n<span class="comment"># Install the coderay gem to get syntax highlighting</span>)
    end
  end

  class CoderayConverter
    def convert(code)
      CodeRay.scan(code, :ruby).html(:line_numbers => false)
    end
  end

  begin
    require 'coderay'
    @@converter = CoderayConverter.new
  rescue LoadError
    @@converter = NullConverter.new
  end

  # @api private
  #
  # Extract lines of code corresponding to  a backtrace.
  #
  # @param [String] backtrace the backtrace from a test failure
  # @return [String] highlighted code snippet indicating where the test failure occured
  #
  # @see #post_process
  def snippet(backtrace)
    raw_code, line = snippet_for(backtrace[0])
    highlighted = @@converter.convert(raw_code)
    post_process(highlighted, line).gsub(/<\/?[^>]*>/, '').gsub(/\n\n+/, "\n").gsub(/^\n|\n$/, '').gsub('&quot;',' ')
  end

  # @api private
  #
  # Create a snippet from a line of code.
  #
  # @param [String] error_line file name with line number (i.e. 'foo_spec.rb:12')
  # @return [String] lines around the target line within the file
  #
  # @see #lines_around
  def snippet_for(error_line)
    if error_line =~ /(.*):(\d+)/
      file = $1
      line = $2.to_i
      [lines_around(file, line), line]
    else
      ["# Couldn't get snippet for #{error_line}", 1]
    end
  end

  # @api private
  #
  # Extract lines of code centered around a particular line within a source file.
  #
  # @param [String] file filename
  # @param [Fixnum] line line number
  # @return [String] lines around the target line within the file (2 above and 1 below).
  def lines_around(file, line)
    if File.file?(file)
      lines = File.read(file).split("\n")
      min = [0, line-3].max
      max = [line+1, lines.length-1].min
      selected_lines = []
      selected_lines.join("\n")
      lines[min..max].join("\n")
    else
      "# Couldn't get snippet for #{file}"
    end
  rescue SecurityError
    "# Couldn't get snippet for #{file}"
    end

  # @api private
  #
  # Adds line numbers to all lines and highlights the line where the failure occurred using html `span` tags.
  #
  # @param [String] highlighted syntax-highlighted snippet surrounding the offending line of code
  # @param [Fixnum] offending_line line where failure occured
  # @return [String] completed snippet
  def post_process(highlighted, offending_line)
    new_lines = []
    highlighted.split("\n").each_with_index do |line, i|
      new_line = "#{offending_line+i-2}----->  #{line}"
      # new_line = new_line.gsub("#{offending_line}----->", "Err -->") if i == 2
      new_lines << new_line
    end
    new_lines.join("\n")
  end

end

class RSpec::Core::Example
  def passed?
    @exception.nil?
  end

  def failed?
    !passed?
  end

  def result!(caseid_prefix="")
    descriptions = @metadata[:description].split('_')
    $result ="Passed"
    if self.failed?
      $result ="Failed"
      message=@exception.to_s      
      exception_backtrace = @exception.backtrace.select{|trace_line| !trace_line.include?("gems/ruby")} #RSpec::Core::BacktraceFormatter.format_backtrace(@exception.backtrace, @metadata)
      backtrace = exception_backtrace.map {|line| relative_path(line)}     
      @snippet_extractor ||= SnippetExtractor.new
      code_source =  @snippet_extractor.snippet(backtrace)      
      unless $driver.nil?
        filename = get_file_name_by_time
        $screenshot=$screenshot << "#{filename};"
        $driver.save_screenshot("#{SCREEN_SHORT_FOLDER}/#{filename}")
      end
      # $errormessage=$errormessage <<Common.timestamp<<" -- #{message}\n#{code_source}\n#{backtrace}"
      expected_data = $step_array.last["expected"] rescue {}
      $step_array.last.delete("expected")
      message = "\nthe #{$step_array.length}th case from #{@metadata[:description]}:\ntest_data: #{$step_array.last.to_json}\nexpected_data: #{expected_data.to_json}\n\n#{message}\n#{code_source}\n#{format_backtrace(backtrace)}"
      $errormessage=$errormessage <<"#{Time.now.strftime("[%Y-%m-%d %H:%M:%S]")} -- #{message}"
      Common.logger_info("#"*22 + "[ERROR MESSAGE]" + "#"*22 + message)
    end
    temp = $errormessage

    descriptions.first.split('##').each do |test_case_id|
      if self.failed?
        Common.logger_info("#"*15 + "[#{test_case_id} FAILED: the #{$step_array.length}th case]" + "#"*15)
      else
        Common.logger_info("#"*15 + "[#{test_case_id} PASSED: total #{$step_array.length} cases]" + "#"*15)
      end
      #TESTPLUS::update_case_result($round_id,$plan_name,test_case_id,$result,$errormessage,$screenshot,$errorlog)
      TESTPLUS.post_case_result({"round_id"=>$round_id,
          "case_id"=>test_case_id,
          "status"=>$result,
          "description"=>$errormessage.to_s,
          "script_name"=>$plan_name,
          "screen_shot"=>$screenshot,
          "server_log"=>$errorlog.to_s}) if "#{test_case_id}".include?(caseid_prefix)
    end
    reset_status
    temp==""
  end

  protected
  def get_file_name_by_time
    t = Time.now
    t.strftime("%Y%m%d-%H-%M-%S-") <<t.nsec.to_s << ".png"
  end

  def reset_status
    $result="Passed"
    $errormessage=""
    $errorlog=""
    $screenshot=""
  end

  def format_backtrace(backtrace)
   return backtrace.join("\n")
  end
  
  def relative_path(line)
    line = line.sub(File.expand_path("."), ".")
    line = line.sub(/\A([^:]+:\d+)$/, '\\1')
    return nil if line == '-e:1'
    line
  rescue SecurityError
    nil
  end

end
