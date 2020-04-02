module CandidateInterface
  class SatisfactionSurveyForm
    include ActiveModel::Model

    attr_accessor :question, :answer

    QUESTIONS_WE_ASK = [
      I18n.t('page_titles.recommendation'),
      I18n.t('page_titles.complexity'),
      'I thought this service was easy to use',
      'I needed help using this service',
      'I found all the parts of this service well-organised',
      'I thought there was too much inconsistency in this website',
      'I would imagine that people would learn to use this website very quickly',
      'I found this website very awkward to use',
      'I felt confident using this service',
      'I needed to learn a lot of things before I could get going with this website',
      'If you could improve anything on Apply for teacher training what would it be?',
      'Is there anything else you would like to tell us?',
      'Are you happy for us to contact you with follow-up questions to your feedback?',
      'Thank you for your feedback',
    ].freeze

    validates :question, presence: true
    validates :question, inclusion: { in: QUESTIONS_WE_ASK, allow_blank: false, message: 'Choose one of the options' }

    def save(application_form)
      return false unless valid?

      application_form.satisfaction_survey ||= {}
      application_form.satisfaction_survey[@question] = @answer
      application_form.save
    end

  private

    def question_already_answered?(application_form)
      application_form.satisfaction_survey&.keys&.include?(@question)
    end

    def merge_satisfaction_survey_and_answer(application_form)
      application_form.satisfaction_survey.merge!({ @question => @answer })
    end
  end
end
