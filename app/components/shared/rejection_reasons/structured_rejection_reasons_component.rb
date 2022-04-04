class RejectionReasons::StructuredRejectionReasonsComponent < ViewComponent::Base
  include ViewHelper

  attr_reader :application_choice, :reasons, :editable

  def initialize(application_choice:, reasons:, editable: false, render_link_to_find_when_rejected_on_qualifications: false)
    @application_choice = application_choice
    @reasons = reasons
    @editable = editable
    @render_link_to_find_when_rejected_on_qualifications = render_link_to_find_when_rejected_on_qualifications
  end

  def editable?
    editable
  end

  def paragraphs(input)
    return [] if input.blank?

    input.split("\r\n")
  end

  def subheading_tag_name
    editable? ? :h2 : :h3
  end

  def link_to_find_when_rejected_on_qualifications(application_choice)
    link = govuk_link_to(
      'Find postgraduate teacher training courses',
      "#{I18n.t('find_postgraduate_teacher_training.production_url')}course/#{application_choice.provider.code}/#{application_choice.course.code}#section-entry",
    )

    "View the course requirements on #{link}.".html_safe
  end
end
