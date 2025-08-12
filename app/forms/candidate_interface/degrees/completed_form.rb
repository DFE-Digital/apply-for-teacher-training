module CandidateInterface
  class Degrees::CompletedForm < Degrees::BaseForm
    validates :completed, presence: true

    def back_link
      if reviewing_and_unchanged_country?
        paths.candidate_interface_degree_review_path
      else
        paths.candidate_interface_degree_university_path
      end
    end

    def next_step
      if reviewing_and_unchanged_country?
        :award_year
      elsif phd?
        :start_year
      else
        :grade
      end
    end
  end
end
