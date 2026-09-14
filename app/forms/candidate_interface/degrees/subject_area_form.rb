module CandidateInterface
  class Degrees::SubjectAreaForm < Degrees::BaseForm
    validates :subject_areas, presence: true

    def back_link
      paths.candidate_interface_degree_subject_path
    end

    def subject_areas

    end
  end
end
