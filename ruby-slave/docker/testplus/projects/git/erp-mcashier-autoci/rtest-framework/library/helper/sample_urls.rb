module Helper
  module SampleUrls
    URLS=YAML.load(File.open("#{File.dirname(__FILE__)}/../../data/webserver_url.yml"))
    class << self
      def testlink_url
        dynamic_web_url = URLS[$env]["TestLink"]
      end
    end
  end
end