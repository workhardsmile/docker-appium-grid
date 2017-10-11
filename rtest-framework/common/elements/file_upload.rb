require_relative "element_base"

class FileUpload < ElementBase
  def upload_file(file_path)
    @@element = element
    if @@element
      if File.exist? file_path
        Common.logger_step "Execute - uploading file via #{self.class} - success. uploading file from #{file_path}"
        @@element.send_keys file_path
      else
        Common.logger_error "Execute - uploading file via #{self.class} - failed. the file does not exist with path #{file_path}"
      end
    else
      Common.logger_error "Execute - uploading file via #{self.class} - failed. can't find element by #{@@type} and #{@@value}"
    end
  end
end
