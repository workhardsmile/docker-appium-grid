require_relative "element_base"
class Table < ElementBase
  def check_row_text(expected_value)
    if exist?
      arr_rows = @@element.find_elements(:tag_name,"tr")
      arr_rows.each do |row|
        if row.text.split.join == expected_value.split.join
          Common.logger_step "Assert  - check text equals to any row of #{self.class} - success"
        return true
        end
      end
      Common.logger_error "Assert  - check text equals to any row of #{self.class} - failed. the row text [#{expected_value.split.join}] not equal to any row"
    else
      Common.logger_error "Assert  - check text equals to any row of #{self.class} - failed. can't find element by #{@@type} and #{@@value}"
    end
  end

  def row_text_include?(expected_value)
    if exist?
      arr_rows = @@element.find_elements(:tag_name,"tr")
      arr_rows.each do |row|
        if row.text.split.join.include? expected_value.split.join
          Common.logger_step "Assert  - check text included in any row of #{self.class} - success"
        return true
        end
      end
      Common.logger_error "Assert  - check text included in any row of #{self.class} - failed. the text [#{expected_value.split.join}] not included in any row"
    else
      Common.logger_error "Assert  - check text included in any row of #{self.class} - failed. can't find element by #{@@type} and #{@@value}"
    end
  end

  def get_row_count
    if exist?
      arr_rows = @@element.find_elements(:tag_name,"tr")
      Common.logger_step "Execute - get row count of #{self.class} - success. there is #{arr_rows.length} rows"
    return arr_rows.length
    else
      Common.logger_error "Execute - click #{self.class} - failed. can't find element by #{@@type} and #{@@value}"
    end
  end

  def get_row_number_by_include_text(include_text)
    arr_tr = []
    if exist?
      arr_tr = @@element.find_elements(:tag_name,"tr")
      arr_tr.length.times do |row_index|
        if arr_tr[row_index].text.include?(include_text)
          Common.logger_step "Execute - get row number #{row_index} of #{self.class} by included row text - success."
        return row_index
        end
      end
      Common.logger_error "Execute - get row number of #{self.class} by included row text - failed. there is no included row text #{include_text}"
    else
      Common.logger_error "Execute - get row number of #{self.class} by included row text - failed. can't find element by #{@@type} and #{@@value}"
    end
  end

  def get_row_arr_data_by_number(row_number)
    if exist?
      row_text_array = []
      arr_tr = @@element.find_elements(:tag_name,"tr")
      arr_td = arr_tr[row_number].find_elements(:tag_name,"td")
      arr_td.each {|td| row_text_array << td.text.split.join}
      if row_text_array.size > 0
        Common.logger_step "Execute - get row text of #{self.class} to array by row number- success."
      return row_text_array
      else
        Common.logger_error "Execute - get row text of #{self.class} to array by row number- failed. there is no column for row #{row_number}"
      end
    else
      Common.logger_error "Execute - get row text of #{self.class} to array by row number- failed. can't find element by #{@@type} and #{@@value}"
    end
  end
  
  def get_all_columns
    if exist?
      items = []
      options = @@element.find_elements(:xpath, "./thead/tr/th")
      options.each{|option| items << $driver.execute_script("return $(arguments[0]).text()",option).to_s}
      Common.logger_step "Execute - #{__method__} in #{self.class} - sucess."
      items
    else
      Common.logger_error "Execute - #{__method__} in #{self.class} - failed. can't find element by #{@@type} and #{@@value}"
    end
  end
  
  def get_column_index_by_column_name(text)
    columns = get_all_columns
    columns.each_with_index do |item_text, index|
    if item_text.strip.include? text.strip
      Common.logger_step "Execute - get index of item in #{self.class} - success. the index of [#{text}] is #{index}"
      return index
      end
    end
    Common.logger_error "Execute - get index of item in #{self.class} - failed. the item [#{text}] is not found"
  end
  
  def get_all_column_row_data_by_column_index(index)
    if exist?
      column_row_data = []
      options = @@element.find_elements(:xpath, "./tbody/tr/td[#{index.to_i+1}]")
      options.each{|option| column_row_data << $driver.execute_script("return $(arguments[0]).text()",option).to_s}
      Common.logger_step "Execute - #{__method__} in #{self.class} - sucess."
      column_row_data
    else
      Common.logger_error "Execute - #{__method__} in #{self.class} - failed. can't find element by #{@@type} and #{@@value}"
    end
  end
  
  def get_all_column_row_data_by_column_name(text)
    column_index = get_column_index_by_column_name(text)
    column_row_data = get_all_column_row_data_by_column_index(column_index)
    column_row_data
  end
end
