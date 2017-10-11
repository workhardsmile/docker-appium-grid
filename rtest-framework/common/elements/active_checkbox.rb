require_relative "element_base"
class ActiveCheckbox < ElementBase
  def selected?
    if exist?
      begin
        result = element.find_element("xpath","./input").attribute("checked")
        if result == "true"
          Common.logger_step "Execute - return if #{self.class} is selected? - success. this checkbox is selected"
          return true
        else
          Common.logger_step "Execute - return if #{self.class} is selected? - success. this checkbox is not selected"
          return false
        end
      rescue Exception => e
        Common.logger_error "Execute - return if #{self.class} is selected? - failed. failed to get the selection status, get error #{e}"
      end
    else
      Common.logger_error "Execute - return if #{self.class} is selected? - failed. can't find element by #{@@type} and #{@@value}"
    end
  end

  def select
    unless selected?
      begin
        element.find_element("xpath", "./label").click
        Common.logger_step "Execute - select checkbox #{self.class} - success."
      rescue Exception => e
        Common.logger_error "Execute - select checkbox #{self.class} - failed. can't select this checkbox, get error #{e}"
      end
    else
      Common.logger_step "Execute - select checkbox #{self.class} - warnning. this element was selected"
    end
  end

  def deselect
    if selected?
      begin
        element.find_element("xpath", "./label").click
        Common.logger_step "Execute - deselect checkbox #{self.class} - success."
      rescue Exception => e
        Common.logger_error "Execute - deselect checkbox #{self.class} - failed. can't deselect this checkbox, get error #{e}"
      end
    else
      Common.logger_step "Execute - deselect checkbox #{self.class} - warnning. this element was NOT selected"
    end
  end

  def get_value
    begin
      element.find("xpath","./input").attribute("value")
    rescue Exception => e
      Common.logger_error "Execute - return value of checkbox #{self.class} - failed. get error #{e}"
    end
  end

  def check_value(expected_value)
    actual_result = get_value
    if expected_value == actual_result
      Common.logger_step "Assert  - check value of #{self.class} - success."
      return true
    else
      Common.logger_error "Assert  - check value of #{self.class} - failed. the expected value is #{expected_value}. the actual result is #{actual_result}"
    end
  end

  def get_property(string_property)
    if exist?
      result = element.attribute(string_property)
      Common.logger_step "Execute - get #{string_property} of #{self.class} - success. get [#{result}] from page."
      if result.nil?
        result = element.find_element(:xpath, ".//input").attribute(string_property)
        Common.logger_step "Execute - reget #{string_property} of #{self.class} - success. get [#{result}] from page."
      end
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
  
  def send_keycode(keycodes)
    if exist?
      begin
        element.send_keys keycodes
      rescue => e
        element.find_element(:xpath, ".//input").send_keys keycodes rescue false
      end
      Common.logger_step "Execute - send keycode [#{keycodes}] to #{self.class} - success."
    else
      Common.logger_error "Execute - send keycode [#{keycodes}] to #{self.class} - failed. can't find element by #{@@type} and #{@@value}"
    end
  end
  
  def should_selected
    if selected? == true
      Common.logger_step "Assert  - verify #{self.class} should be selected - success"
    else
      Common.logger_error "Assert  - verify #{self.class} should be selected - failed. It is NOT selected"
    end
  end

  def should_not_selected
    if selected? == false
      Common.logger_step "Assert  - verify #{self.class} should NOT be selected - success"
    else
      Common.logger_error "Assert  - verify #{self.class} should NOT be selected - failed. It is selected"
    end
  end
  
  def enabled?
    property = get_property("disabled")
    if property.to_s == "true"
      return false
    else
      return true
    end
  end
end
