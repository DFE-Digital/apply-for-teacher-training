module Shared
  class RegionalReportForm
    ALL_REGIONS = 'all'.freeze
    Region = Data.define(:label, :value)
    include ActiveModel::Model

    attr_accessor :region
    validates :region, presence: true

    def options
      result = Publications::RegionalRecruitmentPerformanceReport.regions.each.map do |key, value|
        [value, key]
        Region.new(value, key)
      end
      result.prepend(Region.new('All of England', ALL_REGIONS))
      result
    end

    def save
      valid?
    end
  end
end
