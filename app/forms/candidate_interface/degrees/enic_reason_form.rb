module CandidateInterface
  class Degrees::EnicReasonForm < Degrees::BaseForm
    OBTAINED = 'obtained'.freeze

    validates :enic_reason, presence: true

    def enic_reason_options
      ApplicationQualification.enic_reasons.keys
    end

    def sanitize_attrs(attrs)
      if attrs[:enic_reason].present? && attrs[:enic_reason] != OBTAINED
        attrs[:enic_reference] = nil
        attrs[:comparable_uk_degree] = nil
      end
      attrs
    end

    def back_link
      if reviewing? && complete_unchanged?
        paths.candidate_interface_degree_review_path
      else
        paths.candidate_interface_degree_award_year_path
      end
    end

    def complete_unchanged?
      (existing_degree.predicted_grade == true && predicted_grade) ||
        (existing_degree.predicted_grade == false && completed?)
    end

    def next_step
      if enic_reason == OBTAINED
        :enic_reference
      else
        :review
      end
    end
  end
end
