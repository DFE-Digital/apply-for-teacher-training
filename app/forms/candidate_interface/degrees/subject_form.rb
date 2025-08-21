module CandidateInterface
  class Degrees::SubjectForm < Degrees::BaseForm
    validates :subject, presence: true, length: { maximum: 255 }

    def back_link
      if reviewing_and_unchanged_country?
        paths.candidate_interface_degree_review_path
      elsif degree_has_type?
        paths.candidate_interface_degree_type_path
      else
        paths.candidate_interface_degree_degree_level_path
      end
    end

    def next_step
      if reviewing_and_unchanged_country?
        :review
      else
        :university
      end
    end

    def subjects
      @subjects ||= Hesa::Subject.all
    end

    def subject
      @subject_raw || @subject
    end
  end
end
