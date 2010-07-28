# This script reads the .hl7 files in the hl7/queue folder and attempts to send them via the REST interface.
# This is meant to be run by ruby script/runner by a cron job periodically

hl7_dir = File.join(RAILS_ROOT, OPENMRS_HL7_PATH, "queue/*.hl7")

def get_hl7_message_from_file(filename)
  msg = ''
  f = File.open(filename, "r")
  f.each_line do |line|
    msg += line
  end
  return msg
end

Dir.glob(hl7_dir) do |hl7_file|

  msg = get_hl7_message_from_file(hl7_file)

  # URL Specification
  # http://myhost:serverport/openmrs/moduleServlet/restmodule/api/hl7?message=my_hl7_message_string&source=myHl7SourceName
  # from: http://openmrs.org/wiki/REST_Module

  url = OPENMRS_BASE_URL + "hl7/"      # The trailing slash here is critical.

  # Create a URI object from our url string.
  url = URI.parse(url)

  # Create a request object from our url and attach the authorization data.
  req = Net::HTTP::Post.new(url.path)
  req.basic_auth(OPENMRS_USERNAME, OPENMRS_PASSWORD)
  req.set_form_data({'message' => msg, 'source' => OPENMRS_SENDING_FACILITY})

  http = Net::HTTP.new(url.host, url.port)

  http.use_ssl = true

  begin
    result = http.request(req)
    File.delete(hl7_file)
  rescue
    puts "OpenMRS Down"
  end
end

