module SmsSender

  class TestSender

    @@sent_messages = []

    def send_sms message
      @@sent_messages << message
    end

    def self.sent? message
      @@sent_messages.include? message
    end

    def self.sent_count
      @@sent_messages.size
    end

    def self.clear
      @@sent_messages = []
    end

  end

end

module Test

  module Unit

    module Assertions

      def assert_sms_sent telephone, text
        msg = SmsSender::Message.new(telephone, text)
        sent = SmsSender::TestSender.sent?(msg)
        SmsSender::TestSender.clear
        assert(sent, "Message #{msg} should be sent, but it was not sent.")
      end

      def assert_no_sms_sent
        c = SmsSender::TestSender.sent_count
        SmsSender::TestSender.clear
        assert(c == 0, "No messages should be sent, but #{c} messages was sent")
      end

    end

  end

end