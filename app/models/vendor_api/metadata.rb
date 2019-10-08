module VendorApi
  class Metadata
    include ActiveModel::Validations

    attr_accessor(
      :attribution,
      :timestamp,
    )

    validates_presence_of :attribution
    validates_presence_of :timestamp

    validate :attribution_is_valid, if: -> { attribution.present? }

    def initialize(meta = {})
      meta ||= {}
      @attribution = AttributionMeta.new(meta[:attribution] || {})
      @timestamp = meta[:timestamp]
    end

  private

    def attribution_is_valid
      if @attribution.invalid?
        errors.add(:attribution, "is invalid: #{@attribution.errors.full_messages.to_sentence}")
      end
    end
  end
end
