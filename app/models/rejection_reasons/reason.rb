class RejectionReasons
  class Reason
    include ActiveModel::Model

    attr_accessor :id, :details, :label, :reasons_id, :reasons, :selected_reasons

    def initialize(attrs)
      super(attrs)
      @details = Details.new(attrs[:details]) if attrs.key?(:details)
      @reasons = attrs[:reasons].map { |rattrs| self.class.new(rattrs) } if attrs.key?(:reasons)
    end

    def collection_attribute_names
      return [] unless reasons

      [reasons_id].concat(reasons.map(&:id)).map(&:to_sym)
    end

    def single_attribute_names
      [].tap do |ary|
        ary << details.id.to_sym if details
        ary << id.to_sym unless reasons
      end
    end
  end
end
