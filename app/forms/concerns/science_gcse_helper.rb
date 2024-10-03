module ScienceGcseHelper
  def grade_from(params)
    case params[:gcse_science]
    when ApplicationQualification::SCIENCE_SINGLE_AWARD
      params[:single_award_grade]
    when ApplicationQualification::SCIENCE_DOUBLE_AWARD
      params[:double_award_grade]
    else
      params[:grade]
    end
  end

  def grade_format
    return if
      not_uk_gcse? ||
      grade.nil? ||
      triple_award?

    if %w[gce_o_level scottish_national_5 gcse].include?(qualification.qualification_type) && subject == ApplicationQualification::SCIENCE
      qualification_rexp = invalid_grades[qualification.qualification_type.to_sym]

      errors.add(:grade, :invalid) if qualification_rexp && grade.match(qualification_rexp)
    end

    if gcse_qualification_type? && single_award?
      self.single_award_grade = grade
      errors.add(:single_award_grade, :invalid) unless SINGLE_GCSE_GRADES.include?(sanitize(grade))
    end

    if gcse_qualification_type? && double_award?
      self.double_award_grade = grade

      return if DOUBLE_GCSE_GRADES.include?(sanitize(grade))
      self.grade = 'A*A' and return if sanitize(grade) == 'AA*'
      grade.reverse! and return if DOUBLE_GCSE_GRADES.include?(sanitize(grade).reverse)

      errors.add(:double_award_grade, :invalid)
    end
  end

  def triple_award_grade_format
    return unless triple_award?

    grade_hash = {
      biology_grade:,
      chemistry_grade:,
      physics_grade:,
    }

    grade_hash.each do |key, grade|
      next if grade.blank?

      public_send("#{key}=", grade)
      errors.add(key, :invalid) unless SINGLE_GCSE_GRADES.include?(sanitize(grade))
    end
  end

  def grade_length
    errors.add(:grade, :blank) if grade.blank? && science?
    errors.add(:single_award_grade, :blank) if grade.blank? && single_award?
    errors.add(:double_award_grade, :blank) if grade.blank? && double_award?
    errors.add(:biology_grade, :blank) if biology_grade.blank? && triple_award?
    errors.add(:chemistry_grade, :blank) if chemistry_grade.blank? && triple_award?
    errors.add(:physics_grade, :blank) if physics_grade.blank? && triple_award?
  end

  def invalid_grades
    {
      gcse: /[^1-9A-GU*\s-]/i,
      scottish_national_5: /[^A-D1-7\s-]/i,
    }
  end

  def log_validation_errors(field)
    return unless errors.key?(field)

    error_message = {
      field: field.to_s,
      error_messages: errors[field].join(' - '),
      value: grade || constituent_grades,
    }

    Rails.logger.info("Validation error: #{error_message.inspect}")
  end

  def set_grade
    return if triple_award?

    case grade
    when 'other'
      other_grade
    when 'not_applicable'
      'N/A'
    when 'unknown'
      'Unknown'
    else
      sanitize(grade)
    end
  end

  def set_triple_award_grades
    if triple_award?
      {
        biology: grade_hash(biology_grade),
        physics: grade_hash(physics_grade),
        chemistry: grade_hash(chemistry_grade),
      }
    end
  end

  def grade_hash(grade)
    {
      grade: sanitize(grade),
    }
  end

  def sanitize(grade)
    return grade if not_uk_gcse?

    if ALL_GCSE_GRADES.exclude?(grade) && grade_contains_two_numbers?(grade)
      remove_special_characters_and_add_dash_between_numbers(grade)
    elsif DOUBLE_GCSE_GRADES.exclude?(grade)
      remove_special_characters_and_upcase(grade)
    else
      grade
    end
  end

  def not_uk_gcse?
    qualification.qualification_type.nil? ||
      qualification.qualification_type == 'other_uk' ||
      qualification.qualification_type == 'non_uk'
  end

  def new_record?
    qualification.nil?
  end

  def grade_is_other?
    grade == 'other'
  end

  def triple_award?
    subject == ApplicationQualification::SCIENCE_TRIPLE_AWARD
  end

  def double_award?
    subject == ApplicationQualification::SCIENCE_DOUBLE_AWARD
  end

  def single_award?
    subject == ApplicationQualification::SCIENCE_SINGLE_AWARD
  end

  def science?
    subject == ApplicationQualification::SCIENCE
  end

  def gcse_qualification_type?
    qualification.qualification_type == 'gcse'
  end
  alias gcse? gcse_qualification_type?

  def reset_missing_and_not_completed_explanations!(qualification)
    return true unless qualification.pass_gcse?

    qualification.update(missing_explanation: nil, not_completed_explanation: nil)
  end

  def grade_contains_two_numbers?(grade)
    return false if grade.nil?

    grade.count('0-9') == 2
  end

  def remove_special_characters_and_add_dash_between_numbers(grade)
    grade&.gsub(/[^%\d]/, '')&.insert(1, '-')
  end

  def remove_special_characters_and_upcase(grade)
    grade&.gsub(/[^*\w]/, '')&.upcase
  end
end
