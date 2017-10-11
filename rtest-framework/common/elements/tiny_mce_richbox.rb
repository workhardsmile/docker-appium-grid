require_relative "element_base"
class MceRichbox < ElementBase
  attr_reader :current_tiny_mce
  def input(string_text)
    if exist?
      Common.logger_info "#{self.class}.#{__method__}: #{string_text}"
      $driver.execute_script("return #{@current_tiny_mce}.setContent('#{string_text}');")
    else
      Common.logger_error "Execute - input #{self.class} - failed. can't find element mce js id:#{@@value}" 
    end
  end

  def get_text
    if exist?
      $driver.execute_script("return #{@current_tiny_mce}.getContent();")
    else
      Common.logger_error "Execute - get_text #{self.class} - failed. can't find element mce js id:#{@@value}" 
    end
  end
  
  def clear
    input ""
  end

  def select_all
    if exist?
      $driver.execute_script("return #{@current_tiny_mce}.execCommand('SelectAll');")
    else
      Common.logger_error "Execute - select_all #{self.class} - failed. can't find element bmce js id:#{@@value}" 
    end
  end

  def select_all_and_bold
    select_all
    $driver.execute_script("return #{@current_tiny_mce}.execCommand('bold');")
  end

  def select_all_and_underline
    select_all
    $driver.execute_script("return #{@current_tiny_mce}.execCommand('underline');")
  end

  def select_all_and_italic
    select_all
    $driver.execute_script("return #{@current_tiny_mce}.execCommand('italic');")
  end

  def select_all_and_align_center
    select_all
    $driver.execute_script("return #{@current_tiny_mce}.execCommand('justifycenter');")
  end

  def select_all_and_bulleted_list
    select_all
    $driver.execute_script("return #{@current_tiny_mce}.execCommand('insertunorderedlist');")
  end
  
  def exist?
    @current_tiny_mce = tiny_mce_instance
    if @current_tiny_mce.nil?
      return false
    else
      return true
    end
  end

  def tiny_mce_instance
    js_str = nil
    begin
      $driver.execute_script("return window.parent.tinyMCE.get('#{@@value}').id;")
      js_str = "window.parent.tinyMCE.get('#{@@value}')"
    rescue
      begin
        $driver.execute_script("return tinyMCE.get('#{@@value}').id;")
        js_str = "tinyMCE.get('#{@@value}')"
      rescue 
        js_str = nil
      end
    end
    js_str
  end
end