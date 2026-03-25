module CandidateInterface
  class ResidencyDateForm
    include ActiveModel::Model
    include DateValidationHelper

    attr_accessor :start_date_day, :start_date_month, :start_date_year,
                  :residency_date_from, :application_form

    validates :date, date: { month_and_year: true, presence: true }
    validate :date_must_be_in_the_past
    validate :date_must_not_be_before_birth

    def initialize(attrs = {})
      super
      self.residency_date_from = date
    end

    def save
      return false if invalid?

      application_form.update!(country_residency_date_from: date)
    end

    def date
      valid_or_invalid_date(start_date_year, start_date_month)
    end

    def self.build_from_application(application_form)
      date = application_form.country_residency_date_from

      new(
        application_form: application_form,
        start_date_day: date&.day,
        start_date_month: date&.month,
        start_date_year: date&.year,
      )
    end

  private

    def date_must_be_in_the_past
      return unless date.is_a?(Date)

      if date > Date.current
        errors.add(:date, :in_future)
      end
    end

    def date_must_not_be_before_birth
      return unless date.is_a?(Date)
      return if application_form.date_of_birth.blank?

      if date < application_form.date_of_birth - 1.month
        errors.add(:date, :before_birth)
      end
    end
  end
end
