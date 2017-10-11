require_relative "element_base"
class RadioButton < ElementBase
  def selected?
    if exist?
      Common.logger_step "Execute - return if #{self.class} is selected - success. the selection is [#{@@element.selected?}]"
      @@element.selected?
    else
      Common.logger_error "Execute - return if #{self.class} is selected - failed. can't find element by #{@@type} and #{@@value}"
    end
  end

  def select
    if exist?
      Common.logger_step "Execute - select #{self.class} - success."
      $driver.execute_script("arguments[0].scrollIntoView(false);", @@element);
      element.click unless element.selected?
    else
      Common.logger_error "Execute - select #{self.class} - failed. can't find element by #{@@type} and #{@@value}"
    end
  end

  # will be deprecated, call selected? directly
  def get_value
    selected?
  end

  def check_value(expected_value)
    actual_result = selected?
    if expected_value.to_s == actual_result.to_s
      Common.logger_step "Assert  - verify selection of #{self.class} - success. the selection status is correct"
      true
    else
      Common.logger_error "Assert  - verify selection of #{self.class} - failed. the selection status doesn't match, expected is [#{expected_value}], while actual is [#{actual_result}]"
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

end
