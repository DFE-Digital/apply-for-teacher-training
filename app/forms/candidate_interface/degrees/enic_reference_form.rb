module CandidateInterface
  class Degrees::EnicReferenceForm < Degrees::BaseForm
    validates :enic_reference, :comparable_uk_degree, presence: true

    def next_step
      :review
    end

    def back_link
      if reviewing?
        paths.candidate_interface_degree_review_path
      else
        paths.candidate_interface_degree_enic_path
      end
    end
  end
end
