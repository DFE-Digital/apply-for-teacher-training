class RejectionReasons
  class Reason
    include ActiveModel::Model

    attr_accessor :id, :details, :label, :reasons

    def initialize(attrs)
      super(attrs)
      @details = Details.new(attrs[:details]) if attrs.key?(:details)
      @reasons = attrs[:reasons].map { |hash| self.class.new(hash) } if attrs.key?(:reasons)
    end
  end
end
