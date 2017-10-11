require_relative "element_base"
class Checkbox < ElementBase
  def selected?
    if exist?
      Common.logger_step "Execute - return if #{self.class} is selected? - success. the selection is [#{@@element.selected?}]"
      @@element.selected?
    else
      Common.logger_error "Execute - return if #{self.class} is selected? - failed. can't find element by #{@@type} and #{@@value}"
    end
  end

  def select
    unless selected?
      $driver.execute_script("arguments[0].scrollIntoView(false);", @@element);
      @@element.click
      Common.logger_step "Execute - select checkbox #{self.class} - success."
    else
      Common.logger_step "Execute - select checkbox #{self.class} - warnning. this element was selected"
    end
  end

  def deselect
    if selected?
      $driver.execute_script("arguments[0].scrollIntoView(false);", @@element);
      @@element.click
      Common.logger_step "Execute - deselect checkbox #{self.class} - success."
    else
      Common.logger_step "Execute - deselect checkbox #{self.class} - warnning. this element was NOT selected"
    end
  end

  def get_value
    get_property("value")
  end

  def check_value(expected_value)
    check_property("value",expected_value)
  end
end
