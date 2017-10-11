require "selenium-webdriver"

include Selenium::WebDriver::Error
class ElementBase
  def initialize(type,value,name="#{self.class}")
    @@type=type
    @@value=value
    @@name=name
  end

  def element
    begin
      @@element = $driver.find_element(@@type.to_sym,@@value)
    rescue NoSuchElementError
    return false
    end
  end

  def elements
    $driver.find_elements(@@type.to_sym,@@value)
  end

  def exist?
    @@element = element
    # if @@element
    # @@element.displayed?
    # else
    # return false
    # end
  end

  def click(how=:normal)
    case how
    when :normal
      if exist?
        Common.logger_step "Execute - click #{self.class} - success."
        $driver.execute_script("arguments[0].scrollIntoView(true);", @@element) rescue false
        element.click
      else
        Common.logger_error "Execute - click #{self.class} - failed. can't find element by #{@@type} and #{@@value}"
      end
    when :js
      begin
        $driver.execute_script("arguments[0].click()", element)
      rescue Exception => e
        Common.logger_error "Execute - click #{self.class} via JavaScript - failed, get error message #{e}"
      end
      Common.logger_step "Execute - click #{self.class} via JavaScript - success."
    end
  end

  def should_exist
    if exist?
      Common.logger_step "Assert  - check #{self.class} should exist - success."
    return true
    else
      Common.logger_error "Assert  - check #{self.class} should exist - failed. can't find element by #{@@type} and #{@@value}"
    end
  end

  def should_not_exist
    if exist?
      Common.logger_error "Assert  - check #{self.class} should NOT exist - failed. can find element by #{@@type} and #{@@value} in the page, while it is not expected to show"
    else
      Common.logger_step "Assert  - check #{self.class} should NOT exist - success."
    return true
    end
  end

  def should_selected
    if exist?
      if @@element.selected?
        Common.logger_step "Assert  - check if #{self.class} has been selected. - success."
      return true
      else
        Common.logger_error "Assert  - check if #{self.class} has been selected. - failed. it has not been selected"
      end
    else
      Common.logger_error "Assert  - check if #{self.class} has been selected. - failed. can't find element by #{@@type} and #{@@value}"
    end
  end

  def should_not_selected
    if exist?
      unless @@element.selected?
        Common.logger_step "Assert  - check if #{self.class} has NOT been selected. - success."
      return true
      else
        Common.logger_error "Assert  - check if #{self.class} has NOT been selected. - failed. it has been selected"
      end
    else
      Common.logger_error "Assert  - check if #{self.class} has NOT been selected. - failed. can't find element by #{@@type} and #{@@value}"
    end
  end

  def enabled?
    if exist?
      if @@element.enabled? && "#{get_property("disabled")}"!="true"
        Common.logger_step "Execute - get if #{self.class} enabled? - success. it is enabled"
      return true
      else
        Common.logger_step "Execute - get if #{self.class} enabled? - failed. it is NOT enabled"
      return false
      end
    else
      Common.logger_error "Execute - get if #{self.class} enabled? - failed. can't find element by #{@@type} and #{@@value}"
    end
  end

  def get_property(string_property)
    if exist?
      result = @@element.attribute(string_property)
      Common.logger_step "Execute - get #{string_property} of #{self.class} - success. get [#{result}] from page."
    result.nil? ? result : result.strip
    else
      Common.logger_info "Execute ERROR - get #{string_property} of #{self.class} - failed. can't find element by #{@@type} and #{@@value}"
    false
    end
  end

  def check_property(string_property,expected_result)
    actual_result = get_property(string_property)
    if expected_result == actual_result
      Common.logger_step "Assert  - check #{string_property} of #{self.class} - success."
    return true
    else
      Common.logger_error "Assert  - check #{string_property} of #{self.class} - failed. the expected value is #{expected_result}. the actual result is #{actual_result}"
    end
  end

  def html_include?(expected_value)
    @@element = element
    if @@element
      # actual_value = @@element.attribute("value")
      actual_value = @@element.text
      match_value = Common.string_match_substring_with_regexp(actual_value,expected_value)
      if match_value!=nil
        Common.logger_step "Assert  - #{self.class} should include html #{match_value} - success."
      return true
      else
        Common.logger_error "Assert  - #{self.class} should include html - failed. it don't conatin [#{expected_value}], got [#{actual_value}] from the page"
      end
    else
      Common.logger_error "Assert  - #{self.class} should include html - failed. can't find element by #{@@type} and #{@@value}"
    end
  end

  def text_include?(expected_value,from='ui')
    case from
    when 'ui'
      if exist?
        match_value = Common.string_match_substring_with_regexp(get_text,expected_value)
        if match_value!=nil
          Common.logger_step "Assert  - #{self.class} should include text #{match_value} - success."
        return true
        else
          Common.logger_error "Assert  - #{self.class} should include text - failed. it don't conatin [#{expected_value}]"
        end
      else
        Common.logger_error "Assert  - #{self.class} should include text - failed. can't find element by #{@@type} and #{@@value}"
      end
    # this option will be deprecated. need to update scripts to use html_include? instead.
    when 'dom'
      html_include? expected_value
    end
  end

  def text_not_include?(expected_value)
    actual_value = get_text
    unless actual_value.include? expected_value
      Common.logger_step "Assert  - #{self.class} should NOT include text - success."
    return true
    else
      Common.logger_error "Assert  - #{self.class} should NOT include text - failed. it conatins [#{expected_value}], got [#{actual_value}] from the page"
    end
  end

  def wait_element_disappear(timeout=30)
    # $driver.manage.timeouts.implicit_wait = 0 #set timeout to default
    !timeout.to_i.times do |t|
      sleep 2
      break unless (exist? rescue false)
      if t*2+1 >= timeout
        Common.logger_error "Execute - wait #{self.class} to disapper in #{timeout} secs - failed. the element with #{@@type} and #{@@value} was still found in #{timeout} seconds"
      return false
      end
    end
    Common.logger_info "Execute - wait #{self.class} to disapper in #{timeout} secs - success."
  end

  def wait_element_check_property(string_property,expected_result,timeout=30)
    # $driver.manage.timeouts.implicit_wait = 0 #set timeout to default
    !timeout.to_i.times do |t|
      sleep 2
      break unless (exist? rescue false)
      break if (element.attribute(string_property).to_s == expected_result rescue false)
      if t*2+1 >= timeout
        Common.logger_error "Execute - wait #{string_property} of #{self.class} to change - failed. the element's [#{string_property}] was not changed to [#{expected_result}] in #{timeout} seconds"
      return false
      end
    end
    Common.logger_info "Execute - wait #{string_property} of #{self.class} to change - success. the [#{string_property}] changed to [#{expected_result}]"
  end

  def wait_element_for_text_change(expected_text,timeout=30)
    # $driver.manage.timeouts.implicit_wait = 0 #set timeout to default
    !timeout.to_i.times do |t|
      sleep 2
      break unless (exist? rescue false)
      break if (element.text == expected_text rescue false)
      if t*2+1 >= timeout
        Common.logger_error "Execute - wait text of #{self.class} to change - failed. the element's text was not changed to #{expected_text} in #{timeout} seconds"
      end
    end
    Common.logger_step "Execute - wait text of #{self.class} to change - success. the text changed to [#{expected_text}]"
  end

  def wait_element_present(timeout=30)
    # $driver.manage.timeouts.implicit_wait = 0 #set timeout to default
    !timeout.to_i.times do |t|
      break if (exist? rescue false)
      sleep 1
      if t+1 == timeout
        Common.logger_error "Execute - wait #{self.class} to present - failed. the element with the property #{@@type} and value #{@@value} was not found in #{timeout} seconds"
      end
    end
    Common.logger_step "Execute - wait #{self.class} to present - success. it shows in #{timeout} seconds"
  end

  def mouse_hover
    if exist?
      begin        
        #$driver.action.move_to(@@element).perform
        $driver.action.click_and_hold(@@element).perform
        Common.logger_step "Execute - Hover mouse on #{self.class} - success."
      rescue Exception => e
        Common.logger_error "Execute - Hover mouse on #{self.class} - failed. get error #{e}"
      end
    else
      Common.logger_error "Execute - Hover mouse on #{self.class} - failed. can't find element by #{@@type} and #{@@value}"
    end
  end

  def get_text
    if exist?
      Common.logger_step "Execute - get text of #{self.class} - success. get text [#{@@element.text}]"
    @@element.text
    else
      Common.logger_error "Execute - get text of #{self.class} - failed. can't find element by #{@@type} and #{@@value}"
    end
  end

  def get_html_text
    @@element = element
    if @@element
      actual_value = @@element.attribute('innerHTML')
    else
      Common.logger_error "Assert  - #{self.class} should include html - failed. can't find element by #{@@type} and #{@@value}"
    end
  end

  def html_text_include?(expected_value)
    @@element = element
    if @@element
      actual_value = get_html_text
      match_value = Common.string_match_substring_with_regexp(actual_value,expected_value)
      if match_value!=nil
        Common.logger_step "Assert  - #{self.class} should include html #{match_value} - success."
      return true
      else
        Common.logger_error "Assert  - #{self.class} should include html - failed. it don't conatin [#{expected_value}], got [#{actual_value}] from the page"
      end
    else
      Common.logger_error "Assert  - #{self.class} should include html - failed. can't find element by #{@@type} and #{@@value}"
    end
  end

  def check_text(expected_value)
    actual_value = get_text
    if "#{actual_value}".strip == "#{expected_value}".strip
      Common.logger_step "Assert  - check text of #{self.class} - success."
    return true
    else
      Common.logger_error "Assert  - check text of #{self.class} - failed. get #{actual_value} from page, while #{expected_value} is expected"
    end
  end

  def check_raw_text(expected_value)
    actual_value = get_text.split.join.to_s
    expected_value = expected_value.split.join.to_s
    if actual_value == expected_value
      Common.logger_step "Assert  - check raw text of #{self.class} - success."
    return true
    else
      Common.logger_error "Assert  - check raw text of #{self.class} - failed. get #{actual_value} from page, while #{expected_value} is expected"
    end
  end

  def send_keycode(keycodes)
    if exist?
      @@element.send_keys keycodes
      Common.logger_step "Execute - send keycode [#{keycodes}] to #{self.class} - success."
    else
      Common.logger_error "Execute - send keycode [#{keycodes}] to #{self.class} - failed. can't find element by #{@@type} and #{@@value}"
    end
  end

  def wait_element_clickable(timeout=30)
    loop = (timeout/2).to_i
    loop.times do |i|
      begin
        element.click       
        Common.logger_info "#{self.class}.#{__method__} passed - loop count: #{i}"
        #$driver.mouse.click @element
        return true
      rescue => e
      end
      sleep 2
    end
    Common.logger_error "#{self.class}.#{__method__} - The element was not clickable in #{timeout} seconds"
    return false
  end

  def wait_element_not_clickable(timeout=30)
    loop = (timeout/2).to_i
    loop.times do |i|
      begin
        element.click
        Common.logger_info "#{self.class}.#{__method__} passed - loop count: #{i}"
        sleep 2
        return true unless exist?
      rescue => e
      return true
      end
    end
    Common.logger_error "#{self.class}.#{__method__} - The element was still clickable in #{timeout} seconds"
    return false
  end

  def wait_element_enabled(timeout=30)
    loop = (timeout/2).to_i
    loop.times do |i|
      begin
        flag = element.enabled? && "#{get_property("disabled")}"!="true"
        if flag
          Common.logger_info "#{self.class}.#{__method__} passed - loop count: #{i}"
        return true
        end
      rescue => e
      end
      sleep 2
    end
    Common.logger_error "#{self.class}.#{__method__} - The element was not enabled in #{timeout} seconds"
    return false
  end

  def scroll_into_view
    if exist?
      begin
        $driver.execute_script("arguments[0].scrollIntoView(false);", @@element);
        Common.logger_step "Execute - scoll #{self.class} into view - success."
      rescue Exception => e
        Common.logger_error "Execute - scoll #{self.class} into view - failed. get error #{e}"
      end
    else
      Common.logger_error "Execute - scoll #{self.class} into view - failed. can't find element by #{@@type} and #{@@value}"
    end

  end

end
