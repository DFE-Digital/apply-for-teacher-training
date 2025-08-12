module CandidateInterface
  class Degrees::CountryForm < Degrees::BaseForm
    validates :uk_or_non_uk, presence: true
    validates :country, presence: true, if: :uk_or_non_uk_present?

    delegate :present?, to: :uk_or_non_uk, prefix: true

    def sanitize_attrs(attrs)
      return attrs if attrs[:uk_or_non_uk].blank?

      if attrs[:uk_or_non_uk] == 'uk'
        attrs[:country] = 'GB'
      end

      return attrs if attrs[:country].blank?

      if last_saved_state['country'] != attrs[:country]
        attrs.merge!(
          degree_level: nil, equivalent_level: nil, type: nil, other_type: nil, subject: nil, completed: nil,
          university: nil, start_year: nil, award_year: nil, grade: nil, other_grade: nil, enic_reason: nil,
          enic_reference: nil, comparable_uk_degree: nil
        )
      end

      attrs
    end

    def back_link
      if reviewing?
        paths.candidate_interface_degree_review_path
      else
        paths.candidate_interface_degree_university_degree_path
      end
    end

    def next_step
      if reviewing_and_unchanged_country?
        :review
      elsif uk? || country_with_compatible_degrees?
        :degree_level
      else
        :type
      end
    end
  end
end
