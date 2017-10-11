require_relative "element_base"
class DropdownList < ElementBase
  def get_count_of_options
    if exist?
      arrOption = @@element.find_elements(:tag_name,"OPTION")
      Common.logger_step "Execute - get count of options in #{self.class} - success."
    arrOption.length
    else
      Common.logger_error "Execute - get count of options in #{self.class} - failed. can't find element by #{@@type} and #{@@value}"
    end
  end

  def select_by_index(index)
    load_options
    if enabled? and "#{@@element.attribute("disabled")}" != "true"
      arrOption = @@element.find_elements(:tag_name,"OPTION")
      length = arrOption.length
      if  length > index
        arrOption[index.to_i].click
        Common.logger_step "Execute - select item in #{self.class} by index. - success. select item [#{index}]."
      else
        Common.logger_error "Execute - select item in #{self.class} by index - failed. the index [#{index}] is our of range"
      end
    else
      Common.logger_error "Execute - select item in #{self.class} by index - failed. the element is disalbled or can't find element by #{@@type} and #{@@value}"
    end
  end

  # update for example ["Offer Type","Offer","All"]: can't select "Offer"
  def select_by_item_text(text)
    load_options
    if enabled? and "#{@@element.attribute("disabled")}" != "true"
      arrOption = @@element.find_elements(:tag_name,"OPTION")
      length = arrOption.length
      if text.class != Regexp
        index = get_index_by_item_text("#{text}")      
        if index>=0 && length > index
          arrOption[index.to_i].click
          Common.logger_step "Execute - select item in #{self.class} by text. - success. select item [#{text}]"
          return true
        end
      end
      arrOption.each do |option|
        match_value = Common.string_match_substring_with_regexp(option.text,text)
        if match_value != nil
          option.click
          Common.logger_step "Execute - select item in #{self.class} by text. - success. select item [#{text}]"
          return true
        end
      end
      Common.logger_error "Execute - select item in #{self.class} by text - failed. the item [#{text}] is notfound"
    else
      Common.logger_error "Execute - select item in #{self.class} by text - failed. the element is disalbled or can't find element by #{@@type} and #{@@value}"
    end
  end

  def select_by_value(value)
    load_options
    if enabled? and "#{@@element.attribute("disabled")}" != "true"
      arrOption = @@element.find_elements(:tag_name,"OPTION")
      arrOption.length.times do |i|
        if arrOption[i].attribute("value").strip==value.strip
          arrOption[i].click
          Common.logger_step "Execute - select item in #{self.class} by value. - success. select item [#{value}]"

        return
        elsif i==(arrOption.length-1)
          Common.logger_error "Execute - select item in #{self.class} by value - failed. the item [#{value}] is not found"
        end
      end
    else
      Common.logger_error "Execute - select item in #{self.class} by value - failed. the element is disalbled or can't find element by #{@@type} and #{@@value}"
    end
  end

  # will be deprecated, call select_by_item_text instead.
  def select(option)
    select_by_item_text option
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
      item = nil
      options = @@element.find_elements(:tag_name,"OPTION")
      options.each do |option|
        if option.selected?
        item = option.text.to_s
        break
        end
      end
      Common.logger_step "Execute - get selected item in #{self.class} - sucess. get item [#{item}]."
    item
    else
      Common.logger_error "Execute - get selected item in #{self.class} - failed. can't find element by #{@@type} and #{@@value}"
    end
  end

  def get_all_items
    if exist?
      items = []
      options = @@element.find_elements(:tag_name,"OPTION")
      options.each{|option| items << option.text.to_s.strip}
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
    all_items = get_all_items
    index = all_items.index text.strip
    unless index.nil?
      Common.logger_step "Execute - get index of item in #{self.class} - success. the index of [#{text}] is #{index}"
    index
    else
      Common.logger_error "Execute - get index of item in #{self.class} - failed. the item [#{text}] is not found"
    end
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

  def check_selected_element_property(string_property,expected_value)
    if exist?
      options = @@element.find_elements(:tag_name,"OPTION")
      options.each do |option|
        if option.selected?
          actual_result = option.attribute(string_property)
          if actual_result != expected_value
            Common.logger_error "#{self.class}.#{__method__} - The element with the property #{@@type} and value #{@@value} -  The #{string_property} property does not have the expected value of #{expected_value}. The actual result is #{actual_result}."
          else
            Common.logger_info "#{self.class}.#{__method__} - The #{string_property} property had the correct value of #{expected_value}."
          true
          end
        break
        end
      end
    else
      Common.logger_error "#{self.class}.#{__method__} - The element with the property #{@@type} and value #{@@value} does not exist."
    end
  end
end
