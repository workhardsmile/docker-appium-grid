require 'yaml'
require 'mongo'
require_relative '../../common/utilities/common.rb'

class DatabaseMongo
  def initialize(env=nil)
    env = $env if env.nil?
    @envHash = Hash.new
    #get the database config from ../../data/database.yml by $env
    db_config = YAML.load(File.open("#{File.dirname(__FILE__)}/../../data/database.yml"))
    @envHash[:server] = db_config[env]['mongo']['server']
    @envHash[:password] = db_config[env]['mongo']['password']
    @envHash[:database] = db_config[env]['mongo']['database'] 
    mongo_client  
  end
  
  def mongo_client
     @mongo = Mongo::Client.new(@envHash[:server], @envHash)
  end
  
  def get_video_ids_by_filename(file_name)
    self.get_videos_by_filename(file_name).map{|video| video["_id"]}
  end
  
  def method_missing(method, *args)
    if "#{method}"=~/^get.+by.+/
      parameters = "#{method}".gsub("get_","").split(/(\_by\_)/)
      conditions = parameters[parameters.length-1].split("_and_")
      str_body = parameters[0].split(/\_from\_/)[0..parameters.length-2].reverse!.reduce("@mongo"){|str,p| "#{str}['#{p}']"}
      if args.length == conditions.length       
        index = 0
        parameter_values = conditions.reduce("") do |str,p| 
          index += 1
          "#{str},#{p}:'#{args[index-1]}'"
        end 
        Common.logger_info "#{str_body}.find(#{parameter_values[1..-1]}).to_a"
        results = instance_eval("#{str_body}.find(#{parameter_values[1..-1]}).to_a") 
        # eval, class_eval, instance_eval
        # self.class.class_eval <<-RUBY
          # def #{method}(*args)
            # #{str_body}.find(#{parameter_values[1..-1]}).to_a
          # end
        # RUBY        
        # self.class.send(:define_method, method) do
          # eval("#{str_body}.find(#{parameter_values[1..-1]}).to_a")
        # end
        # results = self.send(method) 
        #block.call #method_missing(method, *args, &block)
        block_given? ? (yield results) : results
      else
        Common.logger_error "Incorrect length of parameter_values: #{conditions} <=> #{args}"
      end
    else 
      Common.logger_error "Incorrect method name: #{method}\n Correct Smaple: get_videos_from_snow_by_filename_and_content_type"
    end
  end
  
  def close
    @mongo.close rescue false
  end
end

# mongo = DatabaseMongo.new("QA")
# puts mongo.mongo_client["locations"].find({:name=>"ShangHai"}).to_a[0]
# puts video_id = mongo.get_videos_by_filename_and_content_type("chengdu-office-part8.mp4","video/mp4"){|results| results[1]["_id"]}
# get_id_form_first_row = lambda {|rows| rows[0]["_id"]} #Proc.new {}
# puts video_id = mongo.get_videos_by_filename("chengdu-office-part8.mp4", &get_id_form_first_row)
# mongo.close


