class RejectionReasons
  class Reason
    include ActiveModel::Model

    attr_accessor :id, :details, :label, :reasons_id, :reasons, :selected_reasons

    def initialize(attrs)
      super(attrs)
      @details = Details.new(attrs[:details]) if attrs.key?(:details)
      @reasons = attrs[:reasons].map { |rattrs| self.class.new(rattrs) } if attrs.key?(:reasons)
    end
  end
end
