module RejectionReasons::ComponentHelper
  def editable?
    editable
  end

  def paragraphs(input)
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
