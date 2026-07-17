module CandidateInterface
  class PersonalDetailsForm
    include ActiveModel::Model

    attr_accessor :first_name, :last_name, :has_previous_last_names, :previous_last_names, :day, :month, :year

    validates :first_name, presence: true, length: { maximum: 60 }
    validates :has_previous_last_names, presence: true
    validates :previous_last_names, presence: true, if: :previous_last_names_declared?
    validates :last_name, presence: true, length: { maximum: 60 }
    validates :date_of_birth, date: { date_of_birth: true, presence: true }

    def self.build_from_application(application_form, state: :edit)
      new(
        first_name: application_form.first_name,
        last_name: application_form.last_name,
        has_previous_last_names: assign_has_previous_last_names(state, application_form),
        previous_last_names: application_form.previous_last_names,
        day: application_form.date_of_birth&.day,
        month: application_form.date_of_birth&.month,
        year: application_form.date_of_birth&.year,
      )
    end

    def save(application_form)
      return false unless valid?

      application_form.update(
        first_name:,
        last_name:,
        previous_last_names: previous_last_names_declared? ? previous_last_names : nil,
        date_of_birth:,
      )
    end

    def name
      "#{first_name} #{last_name}"
    end

    def date_of_birth
      date_args = [year, month, day].map(&:to_i)

      begin
        Date.new(*date_args)
      rescue ArgumentError, RangeError
        Struct.new(:day, :month, :year).new(day, month, year)
      end
    end

    def all_errors
      validate
      errors
    end

    def valid_for_submission?
      all_errors.blank?
    end

    def self.assign_has_previous_last_names(state, application_form)
      return unless state == :edit

      application_form.previous_last_names.present? ? 1 : 0
    end

  private

    def previous_last_names_declared?
      has_previous_last_names.to_i.positive?
    end
  end
end
