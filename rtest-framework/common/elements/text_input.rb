require_relative "element_base"
class TextInput < ElementBase
  def input(string_text,method=:normal)
    if exist?
      case method
      when :normal
        clear
        element.send_keys string_text
        Common.logger_step "Execute - input text to #{self.class} - success. [#{string_text}] is entered"
      when :js
        begin
          $driver.execute_script("return arguments[0].value='#{string_text}'", @@element)
          $driver.execute_script("$(arguments[0]).change()", @@element)
          Common.logger_step "Execute - input text to #{self.class} via JavaScript - success. [#{string_text}] is entered"
        rescue Exception => e
          Common.logger_error "Execute - input text to #{self.class} via JavaScript - failed. get error -> #{e}"
        end
      when :append
        @@element.send_keys string_text
        Common.logger_step "Execute - append text to #{self.class} - success. [#{string_text}] is appeened"
      end      
    else
      Common.logger_error "Execute - input text to #{self.class} - failed. can't find element by #{@@type} and #{@@value}"
    end
  end

  def clear
    if exist?
      begin
        @@element.clear
      rescue Selenium::WebDriver::Error::UnsupportedOperationError
        if $OS == :macosx
          @@element.send_keys [:command, 'a'],:backspace
        else
          @@element.send_keys [:control, 'a'],:backspace
        end
      end
      Common.logger_step "Execute - clear text of #{self.class} - success."
    else
      Common.logger_error "Execute - clear text of #{self.class} - failed. can't find element by #{@@type} and #{@@value}"
    end
  end

  def get_text
    if exist?
      text = @@element.attribute('value')
      Common.logger_step "Execute - get text of #{self.class} - success. get [#{text}] from page"
    return text
    else
      Common.logger_error "Execute - get text of #{self.class} - failed. can't find element by #{@@type} and #{@@value}"
    end
  end

end
