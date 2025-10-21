module GcseQualificationHelper
  def select_gcse_qualification_type_standard_options
    option = Struct.new(:id, :label)

    t('application_form.gcse.qualification_types')
      .except(:other_uk, :non_uk, :missing)
      .map { |id, label| option.new(id, label) }
  end

  def grade_explanation_step_title(subject)
    t("gcse_edit_grade_explanation.page_titles.#{subject}")
  end

  def grade_explanation_subject_title(subject)
    t("gcse_edit_grade_explanation.subject_titles.#{subject}")
  end

  def grade_enic_step_title(subject)
    subject = subject.capitalize if subject == 'english'
    t('gcse_enic.page_title', subject:)
  end

  def grade_step_title(subject, qualification_type)
    subject = subject.capitalize if subject == 'english'
    t('gcse_edit_grade.page_title', subject:, qualification_type: get_qualification_type_name(qualification_type))
  end

  def year_step_title(subject, qualification_type)
    subject = subject.capitalize if subject == 'english'
    t('gcse_edit_year.page_title', subject:, qualification_type: get_qualification_type_name(qualification_type))
  end

  def capitalize_english(subject)
    subject == 'english' ? 'English' : subject
  end

  def failing_grade_row_value(application_qualification)
    return application_qualification.not_completed_explanation if application_qualification.not_completed_explanation.present?

    case application_qualification.currently_completing_qualification
    when true
      'Yes'
    when false
      'No'
    when nil
      'Not provided'
    end
  end
  alias not_completed_explanation_value_row failing_grade_row_value

private

  def get_qualification_type_name(qualification_type)
    if %w[gcse gce_o_level scottish_national_5].include?(qualification_type)
      t('application_form.gcse.qualification_types')[qualification_type.parameterize.underscore.to_sym]
    else
      'qualification'
    end
  end
end
