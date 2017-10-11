require_relative "element_base"
class DropdownMenu < ElementBase

  def get_count_of_options
    if exist?
      arrOption = @@element.find_elements(:xpath, ".//ul[contains(@class,'dropdown-menu')]/li/a")
      Common.logger_step "Execute - get count of options in #{self.class} - success."
      arrOption.length
    else
      Common.logger_error "Execute - get count of options in #{self.class} - failed. can't find element by #{@@type} and #{@@value}"
    end
  end

  def open_dropdown_menu
    begin
      @@element ||= element
      # scroll into view to top window before open menu
      $driver.execute_script("arguments[0].scrollIntoView(true);", @@element) rescue false
      unless @@element.attribute("class").include? "open"
        load_options
        # @@element.find_element(:xpath, "./button[@data-toggle='dropdown']").click
        $driver.execute_script("$(arguments[0]).click();",  @@element.find_element(:xpath, "./button[contains(@class,'dropdown-toggle')]"))
      end
    rescue Exception => e
      Common.logger_error "Execute - open dropdown menu of #{self.class} - failed. get error #{e}"
    end
  end

  def select_by_index(index)
    open_dropdown_menu
    if enabled? and "#{@@element.find_element(:xpath, ".//button").attribute("disabled")}" != "true"     
      arrOption = @@element.find_elements(:xpath, ".//ul[contains(@class,'dropdown-menu')]/li/a")
      if  arrOption.length > index
        arrOption[index.to_i].click
        Common.logger_step "Execute - select item in #{self.class} by index. - success. select item [#{index}]."
      else
        Common.logger_error "Execute - select item in #{self.class} by index - failed. the index [#{index}] is our of range"
      end
    else
      Common.logger_error "Execute - select item in #{self.class} by index - failed. the element is disalbled or can't find element by #{@@type} and #{@@value}"
    end
  end

  def select_by_item_text(text)
    open_dropdown_menu
    if enabled? and "#{@@element.find_element(:xpath, ".//button").attribute("disabled")}" != "true"      
      obj = @@element.find_element(:xpath, ".//ul[contains(@class,'dropdown-menu')]//a[.='#{text}']") rescue nil
      obj = @@element.find_element(:xpath, ".//ul[contains(@class,'dropdown-menu')]//a[contains(.,'#{text}')]") if obj == nil
      # $driver.execute_script("arguments[0].scrollIntoView(false);", obj) rescue false
      obj.click
      $driver.execute_script("arguments[0].click();",obj) rescue false
      Common.logger_step "Execute - select item in #{self.class} by text. - success. select item [#{text}]"
    else
      Common.logger_error "Execute - select item in #{self.class} by text - failed. the element is disalbled or can't find element by #{@@type} and #{@@value}"
    end
  end

  def select_by_value(value)
    open_dropdown_menu
    if enabled? and "#{@@element.find_element(:xpath, ".//button").attribute("disabled")}" != "true"      
      begin
        @@element.find_element(:xpath, ".//ul[contains(@class,'dropdown-menu')]//a[contains(@data-value,'#{value}')]").click
        Common.logger_step "Execute - select item in #{self.class} by text. - success. select item [#{value}]"
      rescue Exception => e
        Common.logger_error "Execute - select item in #{self.class} by text - failed. failed to select item [#{value}], get error #{e}"
      end
    else
      Common.logger_error "Execute - select item in #{self.class} by text - failed. the element is disalbled or can't find element by #{@@type} and #{@@value}"
    end
  end


  def check_selected_item(expected_value)
    selected_item = get_selected_item
    if selected_item.strip == expected_value.strip
      Common.logger_step "Assert  - check seleted item in #{self.class} - success."
      true
    else
      Common.logger_error "Assert  - check seleted item in #{self.class} - failed. get item [#{selected_item.strip}] while [#{expected_value.strip}] is expected"
    end
  end

  def check_item_by_index(index, expected_value)
    item_by_index = get_item_by_index(index).strip
    if item_by_index == expected_value.strip
      Common.logger_step "Assert  - check item in #{self.class} by index - success."
      return true
    else
      Common.logger_error "Assert  - check item in #{self.class} by index - failed. get [#{item_by_index}] for item [#{index}] while [#{expected_value.strip}] is expected"
    end
  end

  def get_selected_item
    if exist?
      item = @@element.find_element(:xpath, ".//button/span[@data-bind='label']")
      Common.logger_step "Execute - get selected item in #{self.class} - sucess. get item [#{item.text}]."
      item.text
    else
      Common.logger_error "Execute - get selected item in #{self.class} - failed. can't find element by #{@@type} and #{@@value}"
    end
  end

  def get_all_items
    if exist?
      items = []
      options = @@element.find_elements(:xpath, ".//ul[contains(@class,'dropdown-menu')]/li/a")
      options.each{|option| items << $driver.execute_script("return $(arguments[0]).text()",option).to_s.strip}
      Common.logger_step "Execute - get all items in #{self.class} - sucess."
      items
    else
      Common.logger_error "Execute - get all items in #{self.class} - failed. can't find element by #{@@type} and #{@@value}"
    end
  end

  def get_item_by_index(index)
    all_items = get_all_items
    if  all_items.length > index
      all_items[index]
    else
      Common.logger_error "Execute - get item from #{self.class} by index - success. get item [#{all_items[index]}]"
    end
  end

  def get_index_by_item_text(text)
    get_all_items.each_with_index do |item_text, index|
      if item_text.strip.include? text.strip
        Common.logger_step "Execute - get index of item in #{self.class} - success. the index of [#{text}] is #{index}"
        return index
      end
    end
    Common.logger_error "Execute - get index of item in #{self.class} - failed. the item [#{text}] is not found"
  end

  def check_included_item(text)
    load_options
    all_items = get_all_items
    index = all_items.index text.strip
    unless index.nil?
      Common.logger_step "Assert  - check item exist in #{self.class} - success."
    else
      Common.logger_error "Assert  - check item exist in #{self.class} - failed. the item [#{text}] is not found"
    end
  end
  
  def check_not_included_item(text)
    load_options
    all_items = get_all_items
    index = all_items.index text.strip
    if index.nil?
      Common.logger_step "Assert  - check item not exist in #{self.class} - success."
    else
      Common.logger_error "Assert  - check item not exist in #{self.class} - failed. the item [#{text}] is found"
    end
  end

  def check_selected_item_value(expected_value)
    if exist?
      item_value = @@element.find_element(:xpath, ".//button/span[@data-bind='label']").attribute("data-value")
      if item_value == expected_value
        Common.logger_step "Assert  - check value of seleted item in #{self.class} - success."
        true
      else
        Common.logger_error "Assert  - check value of selected item for #{self.class} - failed. get value [#{item_value.strip}] while [#{expected_value.strip}] is expected"
      end
    else
      Common.logger_error "Assert  - check value of selected item for #{self.class} - failed. can't find element by #{@@type} and #{@@value}"
    end
  end
  
  def get_property(string_property)
    if exist?
      result = @@element.attribute(string_property)
      Common.logger_step "Execute - get #{string_property} of #{self.class} - success. get [#{result}] from page."
      if result.nil?
        result = @@element.find_element(:xpath, ".//button").attribute(string_property)
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
  
  def load_options(timeout=10,option_text=nil)
    wait_element_present
    timeout.times.each do |i|
      if get_count_of_options > 1
        unless option_text.nil?
          next if get_all_items.index(option_text).nil?
        end
        Common.logger_step "load options for #{self.class} successfully"
        return true
      else
        sleep 1
        Common.logger_step "load options for #{self.class} time:#{i}"
      end
    end
    Common.logger_info "load options for #{self.class} failed, timeout:#{timeout}"
    false
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
