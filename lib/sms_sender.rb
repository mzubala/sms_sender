module SmsSender

  def create_sms_sender
    if Rails.env == "test"
      TestSender.new
    else
      SmsApiSender.new logger
    end
  end

end