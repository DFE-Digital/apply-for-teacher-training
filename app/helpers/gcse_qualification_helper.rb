module GcseQualificationHelper
  def select_gcse_qualification_type_options
    option = Struct.new(:id, :label)

    t('application_form.gcse.qualification_types').map { |id, label| option.new(id, label) }
  end

  def hint_for_gcse_edit_grade(subject, qualification_type)
    subject = subject == 'science' ? 'science' : 'other'
    if I18n.exists?("gcse_edit_grade.hint.#{subject}.#{qualification_type}")
      t("gcse_edit_grade.hint.#{subject}.#{qualification_type}")
    end
  end

  def grade_step_title(subject, qualification_type)
    subject = subject.capitalize if subject == 'english'
    t('gcse_edit_grade.page_title', subject: subject, qualification_type: get_qualification_type_name(qualification_type))
  end

  def year_step_title(subject, qualification_type)
    subject = subject.capitalize if subject == 'english'
    t('gcse_edit_year.page_title', subject: subject, qualification_type: get_qualification_type_name(qualification_type))
  end

private

  def get_qualification_type_name(qualification_type)
    if %w[gcse gce_o_level scottish_national_5].include?(qualification_type)
      t('application_form.gcse.qualification_types')[qualification_type.parameterize.underscore.to_sym]
    else
      'qualification'
    end
  end
end
