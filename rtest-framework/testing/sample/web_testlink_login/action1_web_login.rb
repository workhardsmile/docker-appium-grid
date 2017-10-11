# encoding: UTF-8
def action_1
  time_str = Time.now.strftime("%Y%m%d%H%M%S")
  
  it "DEMOWEB001_testlink login web sample testing (passed)" do
    $parameters["test_data"].each do |test_data|
      $step_array = $step_array << test_data
      TestflowWeb::TestlinkSample.login_to_home(test_data["request"]["username"],test_data["request"]["password"])
      if "#{test_data["expected"]["successs"]}" == "true"
        WebDriver.switch_to_frame_by_name("titlebar")
        TestlinkHome::AccountNameText.new.wait_element_present
        TestlinkHome::AccountNameText.new.text_include?(test_data["request"]["username"])
        WebDriver.switch_to_default_frame
      else
        sleep(3)
        TestlinkLogin::LoginAccountInput.new.should_exist
      end
      #Common.logger_error("testing failed")
    end
  end

  it "DEMOWEB002_testlink login web sample testing(failed)" do
     Common.logger_error("Error and screenshot.")
  end
  
  it "clear and restore" do
    WebDriver.stop_browser
  end
end
