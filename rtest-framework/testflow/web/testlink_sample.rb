# encoding: UTF-8
module TestflowWeb
  class TestlinkSample
    def self.login_to_home(use_name='testlink', password='123456')
      WebDriver.restart_non_blank_browser
      WebDriver.navigate_to_url(Helper::SampleUrls.testlink_url)     
      TestlinkLogin::LoginAccountInput.new.wait_element_clickable
      TestlinkLogin::LoginAccountInput.new.input(use_name)
      TestlinkLogin::PasswordInput.new.input(password)
      TestlinkLogin::LoginButton.new.click    
      #TestlinkLogin::LoginAccountInput.new.wait_element_disappear
    end
    
    def self.logout_from_home
      TestlinkHome::LogoutButton.new.click
      TestlinkHome::AccountNameText.new.wait_element_disappear
      #TestlinkLogin::LoginAccountInput.new.wait_element_present
    end
  end
end