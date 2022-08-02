class VendorAPIRejectionReasons
  class << self
    def codes
      @config ||= YAML.load_file(Rails.root.join('config/rejection_reason_codes.yml'))
    end

    def find(code)
      codes.fetch(code)
    rescue KeyError
      raise RejectionReasonCodeNotFound
    end
  end

  attr_accessor :selected_reasons

  def initialize(reasons_attrs)
    @selected_reasons = reasons_attrs.map do |reason_attrs|
      reason = RejectionReasons::Reason.new(self.class.find(reason_attrs[:code]))
      reason.details.text = reason_attrs[:details]
      reason
    end
  end
end

class RejectionReasonCodeNotFound < StandardError; end
