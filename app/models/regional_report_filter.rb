class RegionalReportFilter < ApplicationRecord
  belongs_to :provider_user
  belongs_to :provider

  enum :region,
       Publications::RegionalRecruitmentPerformanceReport.regions.merge(
         Publications::RegionalRecruitmentPerformanceReport.all_of_england_key =>
           Publications::RegionalRecruitmentPerformanceReport.all_of_england_value,
       )
end
