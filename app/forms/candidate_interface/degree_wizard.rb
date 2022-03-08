module CandidateInterface
  class DegreeWizard
    include Wizard

    class InvalidStepError < StandardError; end

    DEGREE_LEVEL = [
      'Foundation degree',
      'Bachelor degree',
      'Master’s degree',
      'Doctorate (PhD)',
      'Level 6 Diploma',
    ].freeze

    attr_accessor :uk_or_non_uk, :country, :level, :equivalent_level, :subject,
                  :type, :international_type, :other_type, :grade, :have_grade, :other_grade, :university, :completed,
                  :start_year, :award_year, :have_enic_reference, :enic_reference,
                  :comparable_uk_degree, :path_history

    validates :uk_or_non_uk, presence: true, on: :country
    validates :country, presence: true, if: :international?, on: :country
    validates :level, presence: true, on: :level
    validates :equivalent_level, presence: true, length: { maximum: 255 }, if: :other_qualification?, on: :level
    validates :subject, presence: true, length: { maximum: 255 }, on: :subject
    validates :type, presence: true, if: :uk?, on: :type
    validates :international_type, presence: true, length: { maximum: 255 }, if: :international?, on: :type
    validates :other_type, presence: true, length: { maximum: 255 }, if: %i[uk? other_type_selected], on: :type
    validates :university, presence: true, on: :university
    validates :completed, presence: true, on: :completed
    validates :grade, presence: true, if: :uk?, on: :grade
    validates :have_grade, presence: true, if: :international?, on: :grade
    validates :other_grade, presence: true, length: { maximum: 255 }, if: :grade_choices, on: :grade
    validates :start_year, presence: true, on: :start_year
    validates :award_year, presence: true, on: :award_year
    validates :have_enic_reference, presence: true, if: :international?, on: :enic
    validates :enic_reference, :comparable_uk_degree, presence: true, if: -> { have_enic_reference == 'yes' && international? }, on: :enic

    def next_step(step = current_step)
      if step == :country && uk_or_non_uk == 'uk'
        :level
      elsif (step == :country && international? && country.present?) || step == :level
        :subject
      elsif (step == :subject && uk? && level_options?) || step == :type
        :university
      elsif step == :subject
        :type
      elsif step == :university
        :completed
      elsif step == :completed
        :grade
      elsif step == :grade
        :start_year
      elsif step == :start_year
        :award_year
      elsif step == :award_year && international?
        :enic
      elsif (step == :award_year && uk?) || (step == :enic && international?)
        :review
      else
        raise InvalidStepError, 'Invalid Step'
      end
    end

    def attributes_for_persistence
      if uk?
        {
          international: international?,
          qualification_type: qualification_type_attributes,
          qualification_type_hesa_code: hesa_type_code(qualification_type_attributes),
          institution_name: university,
          institution_hesa_code: hesa_institution_code(university),
          subject: subject,
          subject_hesa_code: hesa_subject_code(subject),
          grade: grade_attributes,
          grade_hesa_code: hesa_grade_code(grade_attributes),
          predicted_grade: predicted_grade,
          start_year: start_year,
          award_year: award_year,
        }
      else
        {
          international: international?,
          institution_country: country,
          qualification_type: international_type,
          institution_name: university,
          subject: subject,
          predicted_grade: predicted_grade,
          grade: other_grade,
          start_year: start_year,
          award_year: award_year,
          enic_reference: enic_reference,
          comparable_uk_degree: comparable_uk_degree,
        }
      end
    end

    def sanitize_attrs(attrs)
      if last_saved_state['uk_or_non_uk'] != attrs[:uk_or_non_uk] && attrs[:current_step] == :country
        attrs.merge!(level: nil, type: nil, subject: nil, completed: nil, university: nil,
                     start_year: nil, award_year: nil, international_type: nil, grade: nil)
      end
      attrs
    end

    def predicted_grade
      completed == 'No'
    end

    def hesa_institution_code(institution_name)
      Hesa::Institution.find_by_name(institution_name)&.hesa_code
    end

    def hesa_type_code(type_description)
      Hesa::DegreeType.find_by_name(type_description)&.hesa_code
    end

    def hesa_subject_code(subject)
      Hesa::Subject.find_by_name(subject)&.hesa_code
    end

    def hesa_grade_code(grade)
      Hesa::Grade.find_by_description(grade)&.hesa_code
    end

    def qualification_type_attributes
      return 'Level 6 Diploma' if level == 'Level 6 Diploma'

      type || other_type || equivalent_level
    end

    def grade_attributes
      grade || other_grade
    end

    def international?
      uk_or_non_uk == 'non_uk'
    end

    def uk?
      uk_or_non_uk == 'uk'
    end

    def other_qualification?
      level == 'Another qualification equivalent to a degree'
    end

    def level_options?
      ['Level 6 Diploma', 'Another qualification equivalent to a degree'].include?(level)
    end

    def other_type_selected
      type == "Another #{level.split.first.downcase} degree type"
    end

    def grade_choices
      grade == 'Other' || have_grade == 'Yes'
    end

    def subjects
      @subjects ||= Hesa::Subject.all
    end

    def institutions
      @institutions ||= Hesa::Institution.all
    end
  end
end
