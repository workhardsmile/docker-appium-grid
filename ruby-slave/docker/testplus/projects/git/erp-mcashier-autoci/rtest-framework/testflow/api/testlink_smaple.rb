module TestflowApi
  class TestlinkSample
    def self.testlink_pre_requests(pre_datas, api_base=nil)
      api_base = HttpTestlinkBase.new if api_base.nil?
      (pre_datas || []).each do |pre_data|
        response_body, response = api_base.testlink_request(pre_data["method"],pre_data["api_path"],pre_data["request"])
        puts response_body
      end
    end
  end
end