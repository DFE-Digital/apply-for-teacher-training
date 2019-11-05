module CandidateInterface
  class GcseQualificationDetailsForm
    include ActiveModel::Model

    attr_accessor :grade, :award_year
    validates :grade, :award_year, presence: true

    def save_base(qualification)
      return false unless valid?

      qualification.update!(grade: grade, award_year: award_year)
    end
  end
end
