require_relative "element_base"
class MultipleSelect < ElementBase
  def select_by_index(index)
    if exist?
      arrOption = @@element.find_elements(:tag_name,"OPTION")
      length = arrOption.length
      if  length > index
        arrOption[index.to_i].click
        Common.logger_step "Execute - select item in #{self.class} by index - success. select item by index #{index}"
      else
        Common.logger_error "Execute - select item in #{self.class} by index - failed. the option index is out of range"
      end
    else
      Common.logger_error "Execute - select item in #{self.class} by index - failed. can't find element by #{@@type} and #{@@value}"
    end
  end

  def select(option)
    if exist?
      arrOption = @@element.find_elements(:tag_name,"OPTION")
      arrOption.length.times do |i|
        if arrOption[i].text.strip==option.strip
          arrOption[i].click
          Common.logger_step "Execute - select item in #{self.class} by text - success. select item by text #{option}"
          break
        elsif i==(arrOption.length-1)
          Common.logger_error "Execute - select item in #{self.class} by text - failed. the option #{option} not exist"
        end
      end
    else
      Common.logger_error "Execute - select item in #{self.class} by text - failed. can't find element by #{@@type} and #{@@value}"
    end
  end

  def select_all_options
    if exist?
      options = @@element.find_elements(:tag_name,"OPTION")
      options.each do |option|
        option.click unless option.selected?
      end
      Common.logger_step "Execute - select all items in #{self.class} - success."
    else
      Common.logger_error "Execute - select all items in #{self.class} - failed. can't find element by #{@@type} and #{@@value}"
    end
  end

  def deselect_all_options
    if exist?
      options = @@element.find_elements(:tag_name,"OPTION")
      options.each do |option|
        option.click if option.selected?
      end
      Common.logger_step "Execute - deselect all items in #{self.class} - success."
    else
      Common.logger_error "Execute - deselect all items in #{self.class} - failed. can't find element by #{@@type} and #{@@value}"
    end
  end

  def check_selected_items(array_items)
    temp = get_selected_items
    unless temp.eql? array_items
      Common.logger_error "Assert  - check selected items in #{self.class} - failed. the selected items are not as expected, get #{temp}, while #{array_items} are expected"
    end
  end

  def get_selected_items
    if exist?
      result = []      
      options = @@element.find_elements(:tag_name,"OPTION")
      options.each do |option|
        result << option.text if option.selected?
      end
      Common.logger_step "Execute - get selected items in #{self.class} - success."
      result
    else
      Common.logger_error "Execute - get selected items in #{self.class} - failed. can't find element by #{@@type} and #{@@value}"
    end
  end
end
