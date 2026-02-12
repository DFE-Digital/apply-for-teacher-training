module SupportInterface
  class RegionalReportForm
    Region = Data.define(:label, :value)
    include ActiveModel::Model

    attr_accessor :region
    validates :region, presence: true

    def options
      result = Publications::RegionalRecruitmentPerformanceReport.regions.each.map do |key, value|
        Region.new(value, key)
      end
      result.prepend(
        Region.new(
          Publications::RegionalRecruitmentPerformanceReport.all_of_england_value,
          Publications::RegionalRecruitmentPerformanceReport.all_of_england_key,
        ),
      )
      result
    end

    def save
      valid?
    end
  end
end
