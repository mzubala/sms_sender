module SmsSender

  class Message

    attr_accessor :text, :telephone

    def initialize telephone, text
      @text = text
      @telephone = normalized_telephone telephone
    end

    def == other
      ((other.text || "") == self.text) && ((other.telephone || "") == self.telephone)
    end

    def to_s
      "#{@telephone} - #{@text}"
    end

    private

    def normalized_telephone telephone
      telephone.gsub(/[^\d]/, "")
    end

  end

end
