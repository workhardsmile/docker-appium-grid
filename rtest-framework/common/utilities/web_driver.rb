require 'rubygems'
require 'appium_lib'
require 'thread'

module  WebDriver
  class << self  
    $DOWNLOAD_PATH =File.absolute_path("#{File.dirname(__FILE__)}/../../output/downloads").gsub(File::SEPARATOR, File::ALT_SEPARATOR || File::SEPARATOR)
    def start_remote_browser(ip=nil,port=4444,language=nil)
      puts $platform,ip
      ip = "127.0.0.1" if ip.nil?
      # accept browser types "ie", "firefox", "chrome"
      if $platform == 'firefox'
        caps = Selenium::WebDriver::Remote::Capabilities.firefox
        $driver = Selenium::WebDriver.for(:remote, :desired_capabilities => :firefox, :url => "http://#{ip}:#{port}/wd/hub/")
        $driver.get "about:blank"
        max_width, max_height = $driver.execute_script("return [window.screen.availWidth, window.screen.availHeight];")
        $driver.manage.window.resize_to(max_width, max_height)
      else
        if $platform == 'chrome'
          chrome_switches = ['--start-maximized', '--ignore-certificate-errors', '--disable-popup-blocking', '--disable-translate','-disable-extensions']
          caps_opts = {'chrome.switches' => chrome_switches}
          caps = Selenium::WebDriver::Remote::Capabilities.chrome(caps_opts)
          profile = Selenium::WebDriver::Chrome::Profile.new
          download_path = "#{File.dirname(__FILE__)}/../../output/Downloads"
          Dir.mkdir download_path unless Dir.exist?(download_path)
          caps['download.default_directory'] = download_path
          caps['download.prompt_for_download'] = false
          puts caps,"http://#{ip}:#{port}/wd/hub/"
          $driver = Selenium::WebDriver.for(:remote, :desired_capabilities => caps, :url => "http://#{ip}:#{port}/wd/hub/")
          puts $driver
          $driver.get "about:blank"
        else
          $driver = Selenium::WebDriver.for(:remote, :desired_capabilities => $platform.to_sym, :url => "http://#{ip}:#{port}/wd/hub/")
          $driver.get "about:blank"
          max_width, max_height = $driver.execute_script("return [window.screen.availWidth, window.screen.availHeight];")
        $driver.manage.window.resize_to(max_width, max_height)
        end
      end
      # $driver.manage.timeouts.implicit_wait = 60
      $wait = Selenium::WebDriver::Wait.new(:timeout=>30)
    end
    
    # device: "firefox","chrome","safari","ie", "ie_11","ie_10","ie_9","ie_8","iphone","iphone_plus","ipad","android"
    def start_browser(option={})
      default_option = {
        "device" => $platform,
        "simulate_layout" => "portrait",
      }
      puts default_option
      option = default_option.merge(option)
      case option["device"]
      # when "firefox"
        # start_firefox(option)
      # when "chrome"
        # start_chrome(option)
      # when "safari"
        # send "start_safari_#{$OS.to_s}"
      # when "ie", "ie_11","ie_10","ie_9","ie_8"
        # start_ie(option)
      when "chrome","firefox"
        start_remote_browser($local_ip)
      when "iphone","iphone_plus","ipad","android","ios_reality","ios_simulator","android_reality","android_simulator"
        send "start_mobile_app", option
      end
    end
    
    def stop_browser
      unless $driver.nil?
        $driver.switch_to.alert.dismiss rescue false
        $driver.quit rescue false        
        $driver = nil
      end
    end

    def restart_browser(option={})
      stop_browser
      start_browser(option)
    end

    :private
    def maxmize_window
      $driver.get "about:blank"
      begin
        max_width, max_height = $driver.execute_script("return [window.screen.availWidth, window.screen.availHeight];")
      rescue Exception => e
        Common.logger_info "WARNNING - fail to get screen width and height by JavaScript, set to 1440 * 900"
        max_width = "1440"
        max_height = "900"
      end
      $driver.manage.window.resize_to(max_width, max_height)
      $wait = Selenium::WebDriver::Wait.new(:timeout=>30)
    end

    def start_chrome(option={})
      Common.logger_info "Execute - Start Google Chrome"
      Dir.mkdir $DOWNLOAD_PATH unless Dir.exist?($DOWNLOAD_PATH)
      prefs = {
        :download => {
          :prompt_for_download => false,
          :default_directory => $DOWNLOAD_PATH
        },
      }
      prefs['profile.default_content_settings.multiple-automatic-downloads'] = 1
      switches = %w[--test-type --ignore-certificate-errors --disable-popup-blocking --disable-translate]
      $driver = Selenium::WebDriver.for :chrome, :prefs => prefs, :switches => switches
      maxmize_window
    end

    def start_firefox(option={})
      Common.logger_info "Execute - Start Firefox"
      profile = Selenium::WebDriver::Firefox::Profile.new
      Dir.mkdir $DOWNLOAD_PATH unless Dir.exist?($DOWNLOAD_PATH)
      profile['browser.download.dir'] = $DOWNLOAD_PATH
      profile['browser.download.folderList'] = 2
      profile['browser.helperApps.neverAsk.saveToDisk'] = "application/pdf,text/csv,application/zip"
      profile["intl.accept_languages"] = option["firefox_language_code"] unless option["firefox_language_code"].nil?
      $driver = Selenium::WebDriver.for :firefox, :profile=>profile
      maxmize_window
    end

    def start_ie(option={})
      Common.logger_info "Execute - Start Internet Explorer"
      $driver = Selenium::WebDriver.for :ie
      maxmize_window
    end

    def start_safari_macosx(option={})
      Common.logger_info "Execute - Start Safari on Mac OSX"
      user_agent_string = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_0) AppleWebKit/600.6.3 (KHTML, like Gecko) Version/8.0.6 Safari/600.6.3"
      current_user_agent = `defaults read com.apple.Safari CustomUserAgent`
      unless current_user_agent.include? user_agent_string
        system %Q(defaults write com.apple.Safari CustomUserAgent '"#{user_agent_string}"')
      end
      $driver = Selenium::WebDriver.for :safari
      maxmize_window
    end

    def start_mobile_chrome(option={}, port=4723)
      $local_ip = "127.0.0.1" if $local_ip.nil?
      device = option["device"]
      layout = option["simulate_layout"].to_s
      Common.logger_info "Execute - Start Chrome to simulate mobile browser of #{device} on Windwos"
      
      devices_config = YAML.load_file("#{File.dirname(__FILE__)}/data/user_agent_devices.yml")
      width = devices_config[device][layout]["width"]
      height = devices_config[device][layout]["height"]
      user_agent_string = devices_config[device]["user_agent"]
      # #simulate chrome
      Dir.mkdir $DOWNLOAD_PATH unless Dir.exist?($DOWNLOAD_PATH)
      prefs = {
        :download => {
          :prompt_for_download => false,
          :default_directory => $DOWNLOAD_PATH,
          :timeout => 60
        },
      }
      switches = %w[--test-type --ignore-certificate-errors --disable-popup-blocking --disable-translate]
      switches << "--user-agent=#{user_agent_string}"
      $driver = Selenium::WebDriver.for :chrome, :prefs => prefs,:switches => switches
      $driver.execute_script("window.open(#{$driver.current_url.to_json},'_blank','innerHeight=#{height},innerWidth=#{width}');")
      $driver.close
      $driver.switch_to.window $driver.window_handles.first
      $driver.manage.window.resize_to(width, height)
    end

    def start_mobile_app(option={}, port=4723)
      $local_ip = "127.0.0.1" if $local_ip.nil?
      device = option["device"]
      Common.logger_info "Execute - Start Appium to test app on mobile platform-devices"
      default_config = YAML.load_file("#{File.dirname(__FILE__)}/data/appium_device_config.yml")
      $appium_device_config ||= default_config
      # make sure device node is not nil
      capabilities = $appium_device_config.has_key?(device)? $appium_device_config[device]: default_config[device]
      # make sure each item under device is not nil
      default_config[device].each do |k,v|
        capabilities[k] ||= default_config[device][k]
      end
      Common.logger_info "!!! capabilities:#{capabilities}"
      # Thread.new do
        # appium_cmd = "source ~/.bash_profile;source ~/.profile;killall -9 node; ps -ef|grep 'session-override'|grep -v 'grep'|grep -v 'sh'|awk '{print $2}'|xargs kill -9; sleep 1s&&appium -p #{capabilities['appium_lib']['port']} --session-override"
        # if "#{device}".include?('android_simulator')
          # appium_cmd = "#{appium_cmd} --avd #{capabilities['caps']['deviceName']} &" 
        # elsif "#{device}".include?('reality')
          # appium_cmd = "#{appium_cmd} --udid #{capabilities['caps']['udid']} &"
        # else
          # appium_cmd = "#{appium_cmd} --device-name #{capabilities['caps']['deviceName']} &"
        # end
        # Common.logger_info appium_cmd
        # Common.logger_info `#{appium_cmd}`
        # loop { sleep(1) }
      # end
      sleep(6)
      $appium_driver = Appium::Driver.new(caps: capabilities['caps'], appium_lib: {server_url: "http://#{$local_ip}:#{port}/wd/hub/", session_id: '1143a53b-8cfc-4c03-bc95-366d394facea', wait: (capabilities['caps']['newCommandTimeout'].to_i rescue 0)})
      $driver = $appium_driver.start_driver
      #$appium_driver.export_session
      #$driver = Selenium::WebDriver.for(:remote, :desired_capabilities => capabilities['caps'], :url => capabilities['appium_lib']['server_url'])    
    end
    
    def restart_non_blank_browser(option = {})
      restart_browser(option) if $driver == nil || $driver.current_url.include?("http")
    end 
    
    def open_new_window(height=nil,width=nil)
      max_width, max_height = $driver.execute_script("return [window.screen.availWidth, window.screen.availHeight];")
      height ||= max_height
      width ||= max_width
      $driver.execute_script("window.open(#{$driver.current_url.to_json},'_blank','innerHeight=#{height},innerWidth=#{width}');")
    end
    
    def alert_accept
      alert = $driver.switch_to.alert
      alert.accept
    end

    def alert_dismiss
      alert = $driver.switch_to.alert
      alert.dismiss
    end

    def get_alert_content
      alert = $driver.switch_to.alert
      alert.text
    end

    def switch_browser_by_index (index)
      browsers = $driver.window_handles
      $driver.switch_to.window(browsers[index])
    end

    def switch_to_frame_by_path(path)
      switch_to_default_frame
      path.split('/').each do |p|
        switch_to_frame_by_name p
      end
    end

    def switch_to_frame_by_name(name)
      puts "<-- switch to frame --> #{name}"
      $driver.switch_to.frame($driver.find_element(:name,"#{name}"))
    end

    def switch_to_frame_by_class(class_name)
      puts "<-- switch to frame --> #{class_name}"
      $driver.switch_to.frame($driver.find_element(:class,"#{class_name}"))
    end

    def switch_to_frame_by_id(id)
      puts "<-- switch to frame --> #{id}"
      $driver.switch_to.frame($driver.find_element(:id,"#{id}"))
    end

    def switch_to_frame_by_xpath(xpath)
      puts "<-- switch to frame by xpath --> #{xpath}"
      $driver.switch_to.frame($driver.find_element(:xpath,"#{xpath}"))
    end

    def switch_to_default_frame
      $driver.switch_to.default_content
    end

    def refresh_page
      $driver.navigate.refresh
    end

    def navigate_to_url(url)
      begin
        Common.logger_step "Execute - Navigate to URL #{url} - success."
        $driver.get url
      rescue Timeout::Error
        Common.logger_info "Execute - Navigate to URL #{url} - warnning. get Timeout::Error "
      end
    end

    def get_current_url ()
      $driver.current_url
    end

    def close_browser()
      $driver.quit
    end

    def close_current_window
      $driver.close
    end

    def back
      $driver.navigate.back
    end

    def forward
      $driver.navigate.forward
    end
  end
end

