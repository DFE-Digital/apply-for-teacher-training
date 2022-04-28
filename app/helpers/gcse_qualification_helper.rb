module GcseQualificationHelper
  def select_gcse_qualification_type_options
    option = Struct.new(:id, :label)

    t('application_form.gcse.qualification_types').map { |id, label| option.new(id, label) }
  end

  def grade_explanation_step_title(subject)
    t("gcse_edit_grade_explanation.page_titles.#{subject}")
  end

  def grade_explanation_subject_title(subject)
    t("gcse_edit_grade_explanation.subject_titles.#{subject}")
  end

  def grade_step_title(subject, qualification_type)
    subject = subject.capitalize if subject == 'english'
    if qualification_type == 'international_baccalaureate_middle_years_programme'
      t('gcse_edit_grade.page_title_international_baccalaureate_middle_years_programme', subject: subject)
    else
      t('gcse_edit_grade.page_title', subject: subject, qualification_type: get_qualification_type_name(qualification_type))
    end
  end

  def year_step_title(subject, qualification_type)
    subject = subject.capitalize if subject == 'english'
    t('gcse_edit_year.page_title', subject: subject, qualification_type: get_qualification_type_name(qualification_type))
  end

  def capitalize_english(subject)
    subject == 'english' ? 'English' : subject
  end

private

  def get_qualification_type_name(qualification_type)
    if %w[gcse gce_o_level scottish_national_5 international_baccalaureate_middle_years_programme].include?(qualification_type)
      t('application_form.gcse.qualification_types')[qualification_type.parameterize.underscore.to_sym]
    else
      'qualification'
    end
  end
end
