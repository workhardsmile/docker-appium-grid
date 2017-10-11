# encoding: UTF-8
require 'yaml'
require 'rspec'
require 'rspec/expectations'
require 'rspec/autorun'
require "optparse"

#set up the environment for automation tasks
#hash to hold all options
options = Hash.new
#handle options and arguments
optparse = OptionParser.new do|opts|
  #set the banner
  opts.banner = "Usage: ruby run.rb -s <script_path> [options]"
  
  #define script path option
  options[:script_path] = nil
  opts.on('-s', '--script_path <string>',
  'The script path (required)', 'ex - "camps/bvt/testflow-1", "endurance/regression/testflow-1"') do|script_path|
    options[:script_path] = script_path
  end
  
  #define environment option
  options[:environment] = 'QA'
  opts.on('-e', '--environment <string>', ["QA","REG", "STG", "PROD"],
  'Name of the test environment (optinal)','ex - "QA","REG", "STG", "PROD"','Set to QA by default') do|environment|
    options[:environment] = environment
  end
  
  #define round option
  options[:round] = '1234'
  opts.on('-r', '--round <string>',
  'ID of the test round (optinal)', 'ex - "9999", "8888", "7777"',"Used by Marquee client only, set to 1234 by default ") do|round|
    options[:round] = round
  end
  
  #define platform option
  options[:platform] = 'chrome'
  opts.on('-p', '--platform <string>',
  'Name of the test platform (optinal)', 'ex - "chrome", "iphone"',"Set to chrome by default ") do |platform|
    options[:platform] = platform
  end
  
  #define output option
  options[:output] = nil
  opts.on('-o', '--output <string>',
  'The path of result and log (optinal)', 'ex - "commerce_admin_ui_bug_tracking_t3560-48600-20160903014521.htm", "testing.htm"',"Set to null by default ") do |output|
    options[:output] = output
  end
  
  #define output option
  options[:json] = nil
  opts.on('-j', '--json <string>',
  'Json of the test result (optinal)', 'ex - "{}", "{\"log\":"""}"',"Set to null by default ") do |json|
    options[:json] = json
  end
  
  #define output option
  options[:ip] = '127.0.0.1'
  opts.on('-i', '--ip <string>',
  'IP of localhost (optinal)', 'ex - "127.0.0.1"',"Set to 127.0.0.1 by default ") do |ip|
    options[:ip] = ip
  end

  options[:debug] = false
  opts.on('-d','--debug','show the script result to console') do
    options[:debug] = true
  end

  #define help option
  opts.on_tail("-h", "--help", "Show options help") do
    puts opts
    exit
  end
end

begin
  #parse the command line
  optparse.parse!
  #provide friendy output on missing switches
  mandatory = [:script_path]
  missing = mandatory.select{ |param| options[param].nil? }
  if not missing.empty?
    puts("MISSING OPTIONS: #{missing.join(', ')}")
    puts(optparse)
    exit(1)
  end
rescue OptionParser::InvalidOption, OptionParser::MissingArgument, OptionParser::InvalidArgument
  puts($!.to_s)
  puts(optparse)
  exit(1)
end

script_path = options[:script_path].gsub('\\\\','/').gsub('\\','/').gsub('//','/')
$plan_name= script_path.split('/').last
$env= options[:environment]
$round_id= options[:round]
$platform= options[:platform]
$logfile= options[:output]
$logjson= options[:json]
$local_ip= options[:ip]

#start date
puts "==============Start to testing #{script_path} at #{Time.now.strftime("%Y-%m-%d %H:%M:%S")}"
if options[:debug]
  ARGV.push '-fd'
  require 'pry'
  require 'pry-byebug'
else
  log_path = script_path.include?('testing') ? script_path.split('testing')[0] : ".."
  result_path = $logfile.nil? ? "#{$plan_name}_#{Time.now.strftime("%Y%m%d_%H%M%S")}_#{Time.now.utc.to_i}#{("%03d" % rand(999))}.htm" : $logfile
  ARGV.push '-fh'
  ARGV.push '-o'
  ARGV.push "#{log_path}/output/test_results/#{result_path}"
  puts "You can find test result in: #{log_path}/output/test_results/#{result_path}"
end

folder_path = File.join(File.absolute_path(__FILE__).split("testing")[0],"output")
#puts Dir.getwd.split("test")[0],folder_path
# if File.exist? folder_path
  # FileUtils.remove_dir folder_path,true
# end
Dir.mkdir folder_path unless File.exist?(folder_path)
10.times do |i|
  begin
    if File.exist? folder_path
      path = File.join(folder_path,"screenshots")
      Dir.mkdir path if not File.exist? path
      path = File.join(folder_path,"test_results")
      Dir.mkdir path if not File.exist? path
      break
    end
    sleep 1
    Common.logger_error "Create folder failed in 10 seconds with #{folder_path}" if i>=9
  rescue =>e
  end
end

#init the parameters used for marquee
$result="Passed"
$errormessage=""
$screenshot=""
$error_log=""

#load all the common functions
# Dir[File.dirname(__FILE__) + '/../common/*.rb'].each {|file| require file if file!="./"<<__FILE__}
Dir[File.dirname(__FILE__) + '/../common/*/**/*.rb'].each {|file| require file if file!="./"<<__FILE__}

#load all the libraries under ../library
#Dir.glob("#{File.dirname(__FILE__)}/../library/*/*.rb").each{|f| require f}
Dir.glob("#{File.dirname(__FILE__)}/../library/*/**/*.rb").each{|f| require f}

#load all the libraries under ../testflow
#Dir.glob("#{File.dirname(__FILE__)}/../testflow/*/*.rb").each{|f| require f}
Dir.glob("#{File.dirname(__FILE__)}/../testflow/*/**/*.rb").each{|f| require f}

$global_config = YAML.load(File.open("#{File.dirname(__FILE__)}/../data/global_config.yml"))
#get the paramaters from config.yml for each test plan into $parameters
config_file = script_path.include?('testing') ? "#{script_path}/config.yml" : "#{File.dirname(__FILE__)}/#{script_path}/config.yml"
$parameters=YAML.load(File.open(config_file))

puts "begin running with the configuration..."
puts "environment: #{$env}"
puts "round_id #{$round_id}"
puts "platform: #{$platform}"
puts "logfile: #{$logfile}"
#puts "marquee url: #{$url_string}"
puts "plan name: #{$plan_name}"
service_info = "WebServiceFrontend#v1.0.16|WebServiceBackend#v1.0.19"

describe $plan_name  do
  before(:all){
    RSpec.configure {|c| c.fail_fast = true} if options[:debug]
  }
  after(:all){    
    #TESTPLUS::update_script_state $round_id,$plan_name,"End","1.1.0" 
    TESTPLUS.post_script_status({"round_id"=>$round_id,
        "script_name"=>$plan_name,
        "status"=>"end",
        "versions"=>service_info})
  }
  before(:each) do
    $step_array = [] 
    $errormessage = ""
  end
  after(:each) do |example| 
    example.result!('DEMO')
  end
  files = script_path.include?('testing') ? "#{script_path}/*.rb" : "#{File.dirname(__FILE__)}/#{script_path}/*.rb"
  Dir[files].each {|file| require file}
  $parameters['actions'].split(',').each {|m| send m.strip.to_sym}
end

#end date
puts("==============End to testing #{script_path} at #{Time.now.strftime("%Y-%m-%d %H:%M:%S")}")
