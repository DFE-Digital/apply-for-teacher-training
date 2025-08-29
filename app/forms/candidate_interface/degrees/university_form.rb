module CandidateInterface
  class Degrees::UniversityForm < Degrees::BaseForm
    validates :university, presence: true, length: { maximum: 255 }

    def university
      @university_raw || @university
    end

    def back_link
      if reviewing_and_unchanged_country?
        paths.candidate_interface_degree_review_path
      else
        paths.candidate_interface_degree_subject_path
      end
    end

    def next_step
      if reviewing_and_unchanged_country?
        :review
      else
        :completed
      end
    end

    def institutions
      @institutions ||= Hesa::Institution.all
    end
  end
end
