module ActionController

  class Base

    include SmsSender

    def send_sms telephone, text
      message = Message.new telephone, text
      sender = create_sms_sender
      sender.send_sms message
    end

  end

end