module SmsSender

  def create_sms_sender
    if Rails.env == "test"
      TestSender.new
    else
      SmsApiSender.new logger
    end
  end

end

require "message"
require "test_sender"
require "sms_api_sender"
require "action_controller_ext"
