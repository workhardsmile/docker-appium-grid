def action_block_1
  time_str = Time.now.strftime("%Y%m%d%H%M%S")
  offer_service = WorkflowCommerceCommon::Offers.get_offer_service
  $parameters["data"]["html_css"]["name"] = "csstesting#{time_str}"

  #SOAP = http (post) + xml
  #REST = http (post/put/get/delete=>create/update/select/delete) 
  it "SOAP protocol xml testing" do
    File.open("#{File.dirname(__FILE__)}/sample.xml") do |file|
      doc = REXML::Document.new(file)
      root = doc.root
      agency_id = SQL::Agency_Service.get_agency_data_by_name($parameters["data"]["agency_name"])["id"]
      root.get_elements('//data:findOrganizationUsersByAgencyId/agencyId')[0].text = agency_id
      puts "#######request-->\n#{agency_id}#{root.to_s}"
      return_xml = REXML::Document.new(RestClient.post($parameters["data"]["post_url"], root.to_s, {:use_ssl=>true,:content_type => 'text/xml'}))
      puts "#######response-->\n#{return_xml}"
      puts "#######email: #{return_xml.get_elements('//email')[0].text}"
      puts "#######person_id: #{return_xml.get_elements('//personEnterpriseId')[0].text}"
    end
  end
  
  it "REST protocol json testing" do
    puts "#######post/put-->",offer_service.add_css($parameters["data"]["html_css"]["name"],$parameters["data"]["html_css"]["css_content"],$parameters["data"]["html_css"]["level"])
    puts "#######put-->",offer_service.update_css($parameters["data"]["html_css"]["name"],$parameters["data"]["html_css"]["name"],$parameters["data"]["html_css"]["css_content"],$parameters["data"]["html_css"]["level"])
    puts "#######get-->",offer_service.get_css_info_by_search_text($parameters["data"]["html_css"]["name"])
  end
  
  it "restore env and clean up" do
    WebDriver.close_browser
  end
end
