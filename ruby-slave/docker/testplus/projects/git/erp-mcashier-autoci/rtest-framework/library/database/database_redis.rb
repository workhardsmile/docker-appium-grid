require 'yaml'
require 'redis'

#require_relative '../../common/utilities/common.rb'
class DatabaseRedis
  def initialize(env=nil)
    env = $env if env.nil?
    @envHash = Hash.new
    #get the database config from ../../data/database.yml by $env
    db_config = YAML.load(File.open("#{File.dirname(__FILE__)}/../../data/database.yml"))
    @envHash[:host]=db_config[env]['redis']['host']
    @envHash[:port]=db_config[env]['redis']['port']
    @envHash[:password]=db_config[env]['redis']['password']    
  end
  
  def redis_client
    @redis = Redis.new(@envHash)
  end
end

# redis = DatabaseRedis.new("QA").redis_client
# redis.set:"str1","1234567890"
# p redis.get:"str1"
