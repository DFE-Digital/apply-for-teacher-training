module VendorAPI
  class Metadata
    include ActiveModel::Validations

    attr_accessor(
      :attribution,
      :timestamp,
    )

    validates :attribution, presence: true
    validates :timestamp, presence: true

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
