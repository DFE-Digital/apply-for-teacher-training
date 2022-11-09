class RejectionReasons::RejectionFeedbackSurveyComponent < ViewComponent::Base
  include ViewHelper

  attr_reader :application_choice

  def initialize(application_choice:)
    @application_choice = application_choice
  end

  def answered?
    feedback.present?
  end

  def feedback_text
    if feedback.helpful?
      'You said that this feedback is helpful.'
    else
      'You said that this feedback is not helpful.'
    end
  end

  def feedback
    RejectionFeedback.find_by(application_choice: application_choice)
  end
end
