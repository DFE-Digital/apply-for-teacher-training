module CandidateInterface::Degrees
  class CountryWizard < DegreeWizard
    include Wizard
    include Wizard::PathHistory

    validates :country, presence: true, if: :international?, on: :country

    def back_link
      if reviewing?
        back_to_review
      else
        paths.candidate_interface_degree_university_degree_path
      end
    end

    def next_step
      if reviewing? && !country_changed?
        back_to_review
      else
        :degree_level
      end
    end
  end
end
