module CandidateInterface::Degrees
  class LevelWizard < DegreeWizard
    validates :degree_level, presence: true
    validates :equivalent_level, presence: true, length: { maximum: 255 }, if: :other_uk_qualification?

    OTHER_UK_DEGREE_LEVEL = 'Another qualification equivalent to a degree'.freeze

    UK_DEGREE_LEVEL = [
      'Foundation degree',
      'Bachelor degree',
      'Master’s degree',
      'Doctorate (PhD)',
      'Level 6 Diploma',
      OTHER_UK_DEGREE_LEVEL,
    ].freeze

    NON_UK_OPTIONS = [
      'Bachelor degree',
      'Other',
    ].freeze

    def degree_level_options
      if country_with_compatible_degrees?
        NON_UK_OPTIONS
      else
        UK_DEGREE_LEVEL
      end
    end

    def other_uk_qualification?
      degree_level == OTHER_UK_DEGREE_LEVEL
    end

    def sanitize_attrs(attrs)
      if attrs[:degree_level] != OTHER_UK_DEGREE_LEVEL
        attrs[:equivalent_level] = nil
      end
      attrs
    end

    def back_link
      if reviewing_and_unchanged_country?
        back_to_review
      else
        paths.candidate_interface_degree_country_path
      end
    end

    def next_step
      if reviewing? && !country_changed?
        back_to_review
      else
        :type
      end
    end

    def uk_other_option
      OTHER_UK_DEGREE_LEVEL
    end
  end
end
