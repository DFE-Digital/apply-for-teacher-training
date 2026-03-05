class RegionalReportFilter < ApplicationRecord
  belongs_to :provider_user
  belongs_to :provider

  enum :region, ReportSharedEnums.england_regions_including_england
end
