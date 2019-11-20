module GcseQualificationHelper
  def select_gcse_qualification_type_options
    option = Struct.new(:id, :label)

    t('gcse_edit_type.types').map { |id, label| option.new(id, label) }
  end

  def conditional_radios_for_gcse_qualifications
    { other_uk: [other_uk_qualification_type: 'Enter type of qualification'] }
  end

  def guidance_for_gcse_edit_details(subject, qualification_type)
    if I18n.exists?("gcse_edit_details.guidance.#{subject}.#{qualification_type}")
      tag.p(t("gcse_edit_details.guidance.#{subject}.#{qualification_type}"), class: 'govuk-body')
    end
  end

  def hint_for_gcse_edit_details(subject, qualification_type)
    subject = subject == 'science' ? 'science' : 'other'
    if I18n.exists?("gcse_edit_details.hint.#{subject}.#{qualification_type}")
      t("gcse_edit_details.hint.#{subject}.#{qualification_type}")
    end
  end
end
