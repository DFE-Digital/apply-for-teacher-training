module CandidateInterface::Degrees
  class CountryWizard < DegreeWizard
    validates :uk_or_non_uk, presence: true
    validates :country, presence: true, if: :uk_or_non_uk_present?

    delegate :present?, to: :uk_or_non_uk, prefix: true

    def sanitize_attrs(attrs)
      return attrs unless last_saved_state['uk_or_non_uk'] != attrs[:uk_or_non_uk]

      attrs.merge!(
        degree_level: nil, equivalent_level: nil, type: nil, other_type: nil, subject: nil, completed: nil,
        university: nil, start_year: nil, award_year: nil, grade: nil, other_grade: nil, enic_reason: nil,
        enic_reference: nil, comparable_uk_degree: nil
      )
    end

    def back_link
      if reviewing?
        back_to_review
      else
        paths.candidate_interface_degree_university_degree_path
      end
    end

    def next_step
      if reviewing? && !country_changed?
        back_to_review
      elsif uk? || country_with_compatible_degrees?
        :degree_level
      else
        :type
      end
    end
  end
end
