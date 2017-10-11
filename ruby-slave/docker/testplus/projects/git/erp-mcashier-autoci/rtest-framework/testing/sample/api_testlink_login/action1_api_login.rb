def action_1
  time_str = Time.now.strftime("%Y%m%d%H%M%S")
  api_base = HttpTestlinkBase.new

  it "precondition: create category" do
    TestflowApi::TestlinkSample.testlink_pre_requests($parameters["preconditions"],api_base) unless $parameters["preconditions"].nil?
  end

  it "DEMOAPI001_testlink login api sample testing" do
    $parameters["test_data"].each do |test_data|
      $step_array = $step_array << test_data
      response_data, response = api_base.testlink_request_unsign(test_data["method"],$parameters["api_path"],test_data["request"])
      Common.logger_info("response -->> #{response_data},#{response.code}")
      expect(response.code).to eq(test_data["expected"]["code"])
      expect(response_data).to include(test_data["expected"]["sub_url"])
    end
  end

  it "clear test db" do
    #null
  end
end

