module VendorApi
  class Metadata
    include ActiveModel::Validations

    attr_accessor(
      :attribution,
      :timestamp,
    )

    validates_presence_of :attribution
    validates_presence_of :timestamp

    def initialize(meta = {})
      meta ||= {}
      @attribution = meta[:attribution]
      @timestamp = meta[:timestamp]
    end
  end
end
