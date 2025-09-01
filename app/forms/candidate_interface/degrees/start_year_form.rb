module CandidateInterface
  class Degrees::StartYearForm < Degrees::BaseForm
    validates :start_year, year: true, presence: true
    validate :start_year_is_after_award_year
    validate :start_year_in_future_when_degree_completed

    def start_year_is_after_award_year
      errors.add(:start_year, :after_the_award_year) if award_year.present? && start_year.to_i > award_year.to_i
    end

    def start_year_in_future_when_degree_completed
      errors.add(:start_year, :in_the_future) if completed? && start_year.present? && start_year.to_i >= RecruitmentCycleTimetable.next_year
    end

    def next_step
      if reviewing_and_unchanged_country?
        :review
      else
        :award_year
      end
    end

    def back_link
      if reviewing_and_unchanged_country?
        paths.candidate_interface_degree_review_path
      elsif phd?
        paths.candidate_interface_degree_completed_path
      else
        paths.candidate_interface_degree_grade_path
      end
    end
  end
end
