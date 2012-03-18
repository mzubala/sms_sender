require 'net/http'
require 'digest/md5'

module SmsSender

  class SmsApiSender

    SMS_API_URL = "https://ssl.smsapi.pl/send.do"

    attr_writer :from, :test, :eco, :login, :password

    def initialize logger
      @logger = logger
    end

    def send_sms message
      url = URI.parse(SMS_API_URL)
      req = Net::HTTP::Post.new(url.path)
      params = basic_params message
      add_extra_params(params)
      req.set_form_data(params)
      @logger.info "Requesting sms api to send message: #{truncated_text(message)}"
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      res = http.start { |http| http.request(req) }
      @logger.info "Sms api request finished processing with response #{res.body}"
      if sms_not_sent? res
        raise SmsApiError.new(res.code)
      end
    end

    private

    def basic_params message
      {
        "username" => Rails.configuration.sms_sender_login,
        "password" => Digest::MD5.hexdigest(Rails.configuration.sms_sender_password),
        "to" => message.telephone,
        "message" => truncated_text(message),
        "encoding" => "utf-8"
      }
    end

    def add_extra_params(params)
      params.merge! "from" => Rails.configuration.sms_sender_from if Rails.configuration.respond_to?(:sms_sender_from)
      params.merge! "test" => "1" if Rails.configuration.respond_to?(:sms_sender_test)
      params.merge! "eco" => "1" if Rails.configuration.respond_to?(:sms_sender_eco)
    end

    def sms_not_sent? response
      !response.is_a?(Net::HTTPSuccess) || !(response.body =~ /.*OK.*/)
    end

    def truncated_text message
      text = message.text
      length = [text.length, max_len_of_text(text)].min
      text[0, length]
    end

    def max_len_of_text text
      if text.match SPECIAL_CHARS
        MAX_LEN_SHORT
      else
        MAX_LEN_LONG
      end
    end

    MAX_LEN_SHORT = 201
    MAX_LEN_LONG = 457

    SPECIAL_CHARS = /[^@\u00A3\$\u00A5\u00E8\u00E9\u00F9\u00EC\u00F2\u00C7\u00D8\u00F8\u00C5\u00E5_\^\{\}\[~\]\|\u00C6\u00E6\u00DF\u00C9!"#\u00A4%&'\(\)\*\+\,\-\.\/0-9:;<=>\?A-Z\u00C4\u00D6\u00D1\u00DC\u00A7\u00BFa-z\u00E4\u00F6\u00F1\u00FC\u00E0 \r\n]/

  end

  class SmsApiError

    attr_reader :error_code

    def initialize error_code
      @error_code = error_code
    end

    def to_s
      "Sms Api error code: #{@error_code}"
    end

  end

end