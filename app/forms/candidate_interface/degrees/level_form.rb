module CandidateInterface
  class Degrees::LevelForm < Degrees::BaseForm
    validates :degree_level, presence: true
    validates :equivalent_level, presence: true, length: { maximum: 255 }, if: :other_uk_qualification?

    def degree_level_options
      if country_with_compatible_degrees?
        %w[bachelor other]
      elsif uk?
        ['foundation', 'bachelor', 'master', 'doctor', 'Level 6 Diploma', 'other']
      end
    end

    def other_uk_qualification?
      uk? && degree_level == 'other'
    end

    def sanitize_attrs(attrs)
      if attrs[:degree_level].present? && attrs[:degree_level] != 'other'
        attrs[:equivalent_level] = nil
      end
      attrs
    end

    def back_link
      if reviewing_and_unchanged_country?
        paths.candidate_interface_degree_review_path
      else
        paths.candidate_interface_degree_country_path
      end
    end

    def next_step
      if reviewing_and_unchanged_country? && degree_level_unchanged?
        :review
      elsif degree_has_type?
        :type
      else
        :subject
      end
    end

    def degree_level_unchanged?
      existing_degree.qualification_level == degree_level
    end
  end
end
