require "skycore/version"
require "skycore/payload_builder"

require "crack"
require "httparty"

class Skycore
  API_URL = "https://secure.skycore.com/API/wxml/1.3/index.php"

  #  +api_key+::   your skycore api key (string)
  #  +shortcode+:: shortcode you want to send from (string or number)
  #  +debug+::     print debug logs to stdout (bool, default is false)
  def initialize(api_key, shortcode, debug=false)
    @api_key = api_key
    @shortcode = shortcode
    @debug = debug
  end

  ##
  # save MMS on Skycore servers, send it later
  #
  # +subject+::       MMS subject (String)
  # +text+::          MMS text content (String)
  # +fallback_text+:: SMS fallback text content (will be sent if no MMS is
  #                   available)
  # +attachments+::   Array of attachments, each one is a Hash({type:, url:})
  #                   type may be one of: ["IMAGE", "VIDEO"]
  def save_mms(subject, text, fallback_text, attachments=[])
    do_request builder.build_save_mms(subject, text, fallback_text, attachments)
  end

  ##
  # send saved MMS on Skycore servers, send it later
  #
  # +to+::            Phone number with leading +1 (String)
  # +mms_id+::        MMS ID (string), can be grabbed from
  #                   +save_mms+(...)['MMSID']
  # +fallback_text+:: SMS fallback text content (will be sent if no MMS is
  #                   available). Required even if provided in
  #                   +save_mms+ (only skycore knows why)
  # +options+::       Hash of non-required options
  # * +options[operator_id]+:: Provide operator id (Number)
  # * +options[subject]+::     Override saved subject (String)
  # * +options[content]+::     Override saved content (String)
  def send_saved_mms(to, mms_id, fallback_text, options={})
    operator_id = options[:operator_id]
    subject = options[:subject]
    content = options[:content]
    do_request builder.build_send_saved_mms(@shortcode, to, mms_id, fallback_text,
                                            operator_id, subject, content)
  end

  ##
  # Check if initialized +api_key+ is working
  def login_user
    do_request builder.build_login_user
  end

  protected

  def do_request(payload)
    process_response(send_request(payload))
  end

  def send_request(body)
    dbg "-------------------->"
    dbg body

    res = HTTParty.post(API_URL, {body: body})

    dbg "<--------------------"
    dbg res

    res
  end

  def process_response(xml_string)
    parsed = Crack::XML.parse(xml_string)
    response = parsed["RESPONSE"]

    # Success usually looks like
    #
    # <RESPONSE>
    #   <STATUS>Success</STATUS>
    #   <TO>15551234888</TO>
    #   <MMSID>35674</MMSID>
    # </RESPONSE>
    #
    # Whereas error is usually
    #
    # <RESPONSE>
    #   <STATUS>Failure</STATUS>
    #   <ERRORCODE>E111</ERRORCODE>
    #   <TO>15551234888</TO>
    #   <ERRORINFO>Invalid shortcode</ERRORINFO>
    # </RESPONSE>
    #
    # Raise error with errorcode and errorinfo if things dont go smoothly
    if response["STATUS"] == "Failure" or response["ERRORCODE"]
      raise "Skycore error: #{response["ERRORCODE"]} - #{response["ERRORINFO"]}"
    end

    # Otherwise return serialized response (ruby hash)
    response
  end

  def dbg(str)
    puts str if @debug
  end

  def builder
    @builder ||= PayloadBuilder.new(@api_key)
  end
end
