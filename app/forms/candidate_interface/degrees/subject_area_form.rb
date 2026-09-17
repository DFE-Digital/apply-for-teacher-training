module CandidateInterface
  class Degrees::SubjectAreaForm < Degrees::BaseForm
    validates :subject_areas, presence: true
    validate :valid_number_of_subject_areas

    def subject_groups_list
      @subject_groups_list ||= subject_groups.reject { |subject_area| subject_area.name == 'None of these' }
    end

    def none_of_these_option
      @none_of_these_option ||= subject_groups.find { |subject_area| subject_area.name == 'None of these' }
    end

    def back_link
      if reviewing_and_unchanged_subject?
        paths.candidate_interface_degree_review_path
      else
        paths.candidate_interface_degree_subject_path
      end
    end

    def next_step
      if reviewing_and_unchanged_country?
        :review
      else
        :university
      end
    end

    def valid_number_of_subject_areas
      errors.add(:subject_areas, :too_many) if normalised_subject_areas.size > 2
      errors.add(:subject_areas, :blank) if normalised_subject_areas.empty?
    end
  end
end
