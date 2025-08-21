module CandidateInterface
  class Degrees::EnicReasonForm < Degrees::BaseForm
    HAS_STATEMENT = 'obtained'.freeze
    ENIC_REASON_OPTIONS = ApplicationQualification.enic_reasons.keys

    validates :enic_reason, presence: true, inclusion: { in: ENIC_REASON_OPTIONS }

    def enic_reason_options
      ENIC_REASON_OPTIONS
    end

    def sanitize_attrs(attrs)
      if attrs[:enic_reason] != HAS_STATEMENT
        attrs[:enic_reference] = nil
        attrs[:comparable_uk_degree] = nil
      end
      attrs
    end

    def back_link
      if reviewing?
        paths.candidate_interface_degree_review_path
      else
        paths.candidate_interface_degree_award_year_path
      end
    end

    def next_step
      if enic_reason == HAS_STATEMENT
        :enic_reference
      else
        :review
      end
    end
  end
end
