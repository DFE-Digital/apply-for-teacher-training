module CandidateInterface
  class PersonalDetailsForm
    include ActiveModel::Model
    include ValidationUtils

    attr_accessor :first_name, :last_name,
                  :day, :month, :year

    validates :first_name, :last_name,
              presence: true

    validates :first_name, :last_name,
              length: { maximum: 60 }

    validate :date_of_birth_valid
    validate :date_of_birth_not_in_future
    validate :date_of_birth_is_within_lower_age_limit

    def self.build_from_application(application_form)
      new(
        first_name: application_form.first_name,
        last_name: application_form.last_name,
        day: application_form.date_of_birth&.day,
        month: application_form.date_of_birth&.month,
        year: application_form.date_of_birth&.year,
      )
    end

    def save(application_form)
      return false unless valid?

      application_form.update(
        first_name: first_name,
        last_name: last_name,
        date_of_birth: date_of_birth,
      )
    end

    def name
      "#{first_name} #{last_name}"
    end

    def date_of_birth
      date_args = [year, month, day].map(&:to_i)

      if valid_year?(year) && Date.valid_date?(*date_args)
        Date.new(*date_args)
      else
        Struct.new(:day, :month, :year).new(day, month, year)
      end
    end

    def date_of_birth_valid
      errors.add(:date_of_birth, :invalid) unless date_of_birth.is_a?(Date)
    end

    def date_of_birth_not_in_future
      errors.add(:date_of_birth, :future) if date_of_birth.is_a?(Date) && date_of_birth > Date.today
    end

    def date_of_birth_is_within_lower_age_limit
      return unless date_of_birth.is_a?(Date) && date_of_birth < Date.today

      age_limit = Date.today - 16.years
      errors.add(:date_of_birth, :below_lower_age_limit, date: age_limit.to_s(:govuk_date)) if date_of_birth > age_limit
    end
  end
end
