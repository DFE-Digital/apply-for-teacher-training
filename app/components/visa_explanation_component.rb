class VisaExplanationComponent < ApplicationComponent
  attr_reader :application_choice

  def initialize(application_choice)
    @application_choice = application_choice
  end

  def formatted_content
    explanation = I18n.t(
      "candidate_interface.visa_explanation_component.#{@application_choice.visa_explanation}",
    )

    if @application_choice.visa_explanation_other?
      tag.p("#{explanation}:", class: 'govuk-body govuk-!-margin-bottom-5') +
        tag.p(@application_choice.visa_explanation_details, class: 'govuk-body')
    else
      explanation
    end
  end
end
