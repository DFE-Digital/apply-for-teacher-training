module CandidateInterface
  class Degrees::AwardYearForm < Degrees::BaseForm
    validates :award_year, year: true, presence: true

    validate :award_year_is_before_start_year
    validate :award_year_in_future_when_degree_completed
    validate :award_year_in_past_when_degree_incomplete
    validate :award_year_after_teacher_training_starts

    def award_year_is_before_start_year
      errors.add(:award_year, :before_the_start_year) if start_year.present? && award_year.to_i < start_year.to_i
    end

    def award_year_in_future_when_degree_completed
      errors.add(:award_year, :in_the_future) if completed? && award_year.present? && award_year.to_i > current_year
    end

    def award_year_in_past_when_degree_incomplete
      errors.add(:award_year, :in_the_past) if start_year.present? && predicted_grade && award_year.to_i < recruitment_cycle_year
    end

    def award_year_after_teacher_training_starts
      errors.add(:award_year, :after_teacher_training) if predicted_grade && award_year.to_i > recruitment_cycle_year
    end

    def next_step
      if completed? && international?
        :enic
      else
        :review
      end
    end

    def back_link
      if reviewing_and_unchanged_country?
        paths.candidate_interface_degree_completed_path
      else
        paths.candidate_interface_degree_start_year_path
      end
    end

    def recruitment_cycle_year
      @recruitment_cycle_year ||= ApplicationForm.find(application_form_id).recruitment_cycle_timetable.recruitment_cycle_year
    end

    def current_year
      Time.zone.now.year
    end
  end
end
