require 'yaml'
require 'mysql2'
#require_relative '../../common/utilities/common.rb'

class DatabaseMysql
  def initialize(env)
    env = $env if env.nil?
    @envHash = Hash.new
    #get the database config from ../../data/database.yml by $env
    db_config = YAML.load(File.open("#{File.dirname(__FILE__)}/../../data/database.yml"))
    @envHash[:timeout]=5000
    @envHash[:username]=db_config[env]['mysql']['username']
    @envHash[:password]=db_config[env]['mysql']['password']
    @envHash[:database]=db_config[env]['mysql']['database']
    @envHash[:encoding]= db_config[env]['mysql']['encoding']
    @envHash[:host]=db_config[env]['mysql']['host']
  end

  def query(sql,is_escaped = false)
    Common.logger_info sql
    result = []
    client = Mysql2::Client.new(@envHash)
    begin
      sql = client.escape(sql) if is_escaped
      result = client.query(sql).to_a
      return result
    rescue => e
      Common.logger_error "error in execute_query -- #{sql} \n #{e.message}"
    end
  ensure client.close if client
    end
end
#puts DatabaseMysql.new("QA").query("SELECT VERSION()")
