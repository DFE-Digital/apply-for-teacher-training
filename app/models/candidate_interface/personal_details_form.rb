module CandidateInterface
  class PersonalDetailsForm
    include ActiveModel::Model

    attr_accessor :first_name, :last_name,
                  :day, :month, :year,
                  :first_nationality, :second_nationality,
                  :english_main_language,
                  :english_language_details, :other_language_details

    validates :first_name, :last_name, :english_main_language,
              :first_nationality,
              presence: true

    validates :first_name, :last_name,
              length: { maximum: 100 }

    validate :date_of_birth_valid
    validate :date_of_birth_not_in_future

    validates :first_nationality, :second_nationality,
              inclusion: { in: NATIONALITY_DEMONYMS, allow_blank: true }

    validates :english_language_details, :other_language_details,
              word_count: { maximum: 200 }

    def self.build_from_application(application_form)
      new(
        first_name: application_form.first_name,
        last_name: application_form.last_name,
        first_nationality: application_form.first_nationality,
        second_nationality: application_form.second_nationality,
        english_main_language: boolean_to_word(application_form.english_main_language),
        english_language_details: application_form.english_language_details,
        other_language_details: application_form.other_language_details,
        day: application_form.date_of_birth&.day,
        month: application_form.date_of_birth&.month,
        year: application_form.date_of_birth&.year,
      )
    end

    def self.boolean_to_word(boolean)
      return nil if boolean.nil?

      boolean ? 'yes' : 'no'
    end

    def save(application_form)
      return false unless valid?

      application_form.update(
        first_name: first_name,
        last_name: last_name,
        first_nationality: first_nationality,
        second_nationality: second_nationality,
        english_main_language: english_main_language?,
        english_language_details: english_main_language? ? english_language_details : '',
        other_language_details: english_main_language? ? '' : other_language_details,
        date_of_birth: date_of_birth,
      )
    end

    def date_of_birth
      date_args = [year, month, day].map(&:to_i)
      if Date.valid_date?(*date_args)
        Date.new(*date_args)
      end
    end

    def date_of_birth_valid
      errors.add(:date_of_birth, :invalid) if date_of_birth.nil?
    end

    def date_of_birth_not_in_future
      errors.add(:date_of_birth, :future) if date_of_birth.present? && date_of_birth > Date.today
    end

    def english_main_language?
      english_main_language == 'yes'
    end
  end
end
