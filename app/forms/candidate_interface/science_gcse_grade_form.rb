module CandidateInterface
  class ScienceGcseGradeForm
    include ActiveModel::Model

    attr_accessor :grade,
                  :constituent_grades,
                  :award_year,
                  :qualification,
                  :subject,
                  :other_grade,
                  :single_award_grade,
                  :double_award_grade,
                  :gcse_science,
                  :biology_grade,
                  :physics_grade,
                  :chemistry_grade
    validates :other_grade, presence: true, if: :grade_is_other?
    validate :grade_length
    validate :grade_format, unless: :new_record?
    validate :triple_award_grade_format

    class << self
      def build_from_qualification(qualification)
        if qualification.qualification_type == 'non_uk'
          new(
            grade: qualification.set_grade,
            other_grade: qualification.set_other_grade,
            qualification: qualification,
          )
        else
          new(build_params_from(qualification))
        end
      end

    private

      def build_params_from(qualification)
        params = {
          gcse_science: qualification.subject,
          subject: qualification.subject,
          qualification: qualification,
          award_year: qualification.award_year,
        }

        case qualification.subject
        when ApplicationQualification::SCIENCE_SINGLE_AWARD
          params[:single_award_grade] = qualification.grade
        when ApplicationQualification::SCIENCE_DOUBLE_AWARD
          params[:double_award_grade] = qualification.grade
        when ApplicationQualification::SCIENCE_TRIPLE_AWARD
          grades = qualification.constituent_grades
          return unless grades

          params[:biology_grade] = grades['biology']['grade']
          params[:chemistry_grade] = grades['chemistry']['grade']
          params[:physics_grade] = grades['physics']['grade']
        else
          params[:grade] = qualification.grade
        end

        params
      end
    end

    def save
      unless valid?
        log_validation_errors(errors.attribute_names.first)
        return false
      end

      qualification.update(
        grade: set_grade,
        constituent_grades: set_triple_award_grades,
        subject: subject,
      )
    end

    def assign_values(params)
      self.gcse_science = params[:gcse_science]
      self.grade = set_grade_from(params)
      self.other_grade = params[:other_grade]
      self.subject = params[:gcse_science] || ApplicationQualification::SCIENCE
      self.biology_grade = params[:biology_grade]
      self.chemistry_grade = params[:chemistry_grade]
      self.physics_grade = params[:physics_grade]
      self
    end

  private

    def set_grade_from(params)
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
        qualification.qualification_type.nil? ||
          qualification.qualification_type == 'other_uk' ||
          qualification.qualification_type == 'non_uk' ||
          grade.nil? ||
          triple_award?

      if %w[gce_o_level scottish_national_5 gcse].include?(qualification.qualification_type) && subject == ApplicationQualification::SCIENCE
        qualification_rexp = invalid_grades[qualification.qualification_type.to_sym]
        errors.add(:grade, :invalid) if grade.match(qualification_rexp)
      end

      if gsce_qualification_type? && single_award?
        self.single_award_grade = grade
        errors.add(:single_award_grade, :invalid) unless SINGLE_GCSE_GRADES.include?(sanitize(grade))
      end

      if gsce_qualification_type? && double_award?
        self.double_award_grade = grade
        errors.add(:double_award_grade, :invalid) unless DOUBLE_GCSE_GRADES.include?(sanitize(grade))
      end
    end

    def triple_award_grade_format
      return unless triple_award?

      grade_hash = {
        biology_grade: biology_grade,
        chemistry_grade: chemistry_grade,
        physics_grade: physics_grade,
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
        gcse: /[^1-9A-GU\*\s\-]/i,
        gce_o_level: /[^A-EU\s\-]/i,
        scottish_national_5: /[^A-D1-7\s\-]/i,
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
      grade.delete(' ').upcase if grade
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

    def gsce_qualification_type?
      qualification.qualification_type == 'gcse'
    end
  end
end
