module ProviderInterface
  class LanguageSkillsComponent < ActionView::Component::Base
    validates :application_form, presence: true

    delegate :english_main_language,
             :english_language_details,
             :other_language_details,
             to: :application_form

    def initialize(application_form:)
      @application_form = application_form
    end

    def rows
      [
        english_main_language_row,
        language_details_row,
      ]
    end

  private

    def english_main_language_row
      {
        key: t('application_form.personal_details.english_main_language.label'),
        value: english_main_language ? 'Yes' : 'No',
      }
    end

    def language_details_row
      english_main_language ? english_main_language_details_row : other_language_details_row
    end

    def english_main_language_details_row
      {
        key: t('application_form.personal_details.english_main_language_details.label'),
        value: other_language_details.present? ? other_language_details : 'No details given',
      }
    end

    def other_language_details_row
      {
        key: t('application_form.personal_details.other_language_details.label'),
        value: english_language_details.present? ? english_language_details : 'No details given',
      }
    end

    attr_reader :application_form
  end
end
