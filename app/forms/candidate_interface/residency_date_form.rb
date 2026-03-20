module CandidateInterface
  class ResidencyDateForm
    include ActiveModel::Model
    include DateValidationHelper

    attr_accessor :start_date_day, :start_date_month, :start_date_year, :residency_date_from

    validates :residency_start_date, date: { month_and_year: true, presence: true }

    def save(application)
      return false if invalid?

      application.update(country_residency_date_from: residency_start_date)
    end

    def residency_start_date
      valid_or_invalid_date(start_date_year, start_date_month)
    end

    def self.build_from_application(application)
      new(
        residency_date_from: application.country_residency_date_from,
      )
    end
  end
end
