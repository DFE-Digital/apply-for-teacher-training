module CandidateInterface
  class SatisfactionSurveyForm
    include ActiveModel::Model

    attr_accessor :question, :answer

    QUESTIONS_WE_ASK = [
      I18n.t('page_titles.recommendation'),
      I18n.t('page_titles.complexity'),
      I18n.t('page_titles.ease_of_use'),
      I18n.t('page_titles.help_needed'),
      I18n.t('page_titles.organisation'),
      I18n.t('page_titles.consistency'),
      I18n.t('page_titles.adaptability'),
      I18n.t('page_titles.awkward'),
      I18n.t('page_titles.confidence'),
      I18n.t('page_titles.needed_additional_learning'),
      I18n.t('page_titles.improvements'),
      I18n.t('page_titles.other_information'),
      I18n.t('page_titles.contact'),
    ].freeze

    validates :question, presence: true
    validates :question, inclusion: { in: QUESTIONS_WE_ASK, allow_blank: false, message: 'Choose one of the options' }

    def save(application_form)
      return false unless valid?

      application_form.satisfaction_survey ||= {}
      application_form.satisfaction_survey[@question] = @answer
      application_form.save
    end
  end
end
