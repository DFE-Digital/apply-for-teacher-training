module CandidateInterface
  class LanguagesForm
    include ActiveModel::Model
    include ValidationUtils

    attr_accessor :english_main_language,
                  :english_language_details, :other_language_details

    validates :english_main_language, presence: true

    validates :english_language_details, :other_language_details,
              word_count: { maximum: 200 }

    def self.build_from_application(application_form)
      new(
        english_main_language: boolean_to_word(
          application_form.english_main_language(fetch_database_value: true),
        ),
        english_language_details: application_form.english_language_details,
        other_language_details: application_form.other_language_details,
      )
    end

    def self.boolean_to_word(boolean)
      return nil if boolean.nil?

      boolean ? 'yes' : 'no'
    end

    def save(application_form)
      return false unless valid?

      application_form.update(
        english_main_language: english_main_language?,
        english_language_details: english_main_language? ? nil : english_language_details,
        other_language_details: english_main_language? ? other_language_details : nil,
      )
    end

    def english_main_language?
      english_main_language == 'yes'
    end
  end
end
