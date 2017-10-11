#load all the common functions
# Dir[File.dirname(__FILE__) + '/../common/*.rb'].each {|file| require file if file!="./"<<__FILE__}
Dir[File.dirname(__FILE__) + '/../common/*/**/*.rb'].each {|file| require file if file!="./"<<__FILE__}
#load all the libraries under ../library
#Dir.glob("#{File.dirname(__FILE__)}/../library/*/*.rb").each{|f| require f}
Dir.glob("#{File.dirname(__FILE__)}/../library/*/**/*.rb").each{|f| require f}
#load all the libraries under ../workflow
#Dir.glob("#{File.dirname(__FILE__)}/../workflow/*/*.rb").each{|f| require f}
Dir.glob("#{File.dirname(__FILE__)}/../workflow/*/**/*.rb").each{|f| require f}
$env="QA"
$platform='chrome'
name='api/api_testlink_login'
$parameters=YAML.load(File.open("#{File.dirname(__FILE__)}/#{name}/config.yml"))
paths = $parameters["api_path"].split('/') rescue []
folder_name = "#{name}".gsub("/","_")
puts "###########################Folder###############################"
puts "#{folder_name}", $parameters["api_path"]
#puts "implement interface test script #{paths[-3]}_#{paths[-2]}_#{paths.last.gsub("-","_")}"
steps = expects = pre_steps = ""
($parameters["preconditions"]||[]).each_with_index do |test_data,index|
  pre_steps +="#{index+1}. #{test_data['api_path']}: \n \t#{test_data['method']} #{test_data['request'].to_json}\n"
end
puts "###########################Unsign Test###############################"
puts "#{folder_name} unsign testing"
steps = expects = ""
($parameters["unsign_test_data"]||[]).each_with_index do |test_data,index|
  steps +="#{index+1}. #{test_data['method']} #{test_data['request'].to_json}\n"
  expects +="#{index+1}. #{test_data['expected'].to_json}\n"
end
puts "#{$parameters["api_path"]} testing", pre_steps, "#{$parameters["comments"]}".gsub(/;[\s]{0,1}/,"\n"), "Request:",steps,"Response:",expects
puts "###########################Signin Test###############################"
puts "#{folder_name} signin testing"
steps = expects = ""
($parameters["signin_test_data"]||[]).each_with_index do |test_data,index|
  steps +="#{index+1}. #{test_data['method']} #{test_data['request'].to_json}\n"
  expects +="#{index+1}. #{test_data['expected'].to_json}\n"
end
puts "#{$parameters["api_path"]} testing", pre_steps, "#{$parameters["comments"]}".gsub(/;[\s]{0,1}/,"\n"), "Request:",steps,"Response:",expects

