module ProviderInterface
  class PersonalStatementComponent < ActionView::Component::Base
    validates :application_form, presence: true

    delegate :becoming_a_teacher,
             :subject_knowledge,
             :interview_preferences,
             :further_information,
             to: :application_form

    def initialize(application_form:)
      @application_form = application_form
    end

    def rows
      [
        {
          key: t('application_form.personal_statement.becoming_a_teacher.label'),
          value: becoming_a_teacher,
        },
        {
          key: 'Subject knowledge',
          value: subject_knowledge,
        },
        {
          key: t('application_form.personal_statement.interview_preferences.label'),
          value: interview_preferences.present? ? interview_preferences : 'No preference given',
        },
        {
          key: 'Further information',
          value: further_information.present? ? further_information : 'No further information given',
        },
      ]
    end

  private

    attr_reader :application_form
  end
end
