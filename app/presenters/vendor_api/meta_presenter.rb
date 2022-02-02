module VendorAPI
  class MetaPresenter < Base
    attr_reader :count

    def initialize(version, count = nil)
      super(version)
      @count = count
    end

    def as_json
      meta_hash = {
        api_version: "v#{active_version}",
        timestamp: Time.zone.now.iso8601,
      }
      meta_hash[:total_count] = count if count
      meta_hash.to_json
    end
  end
end
