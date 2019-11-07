module CandidateInterface
  class GcseQualificationDetailsForm
    include ActiveModel::Model

    attr_accessor :grade, :award_year, :qualification_id
    validates :grade, :award_year, :qualification_id, presence: true

    def self.build_from_qualification(qualification)
      new(
        grade: qualification.grade,
        award_year: qualification.award_year,
        qualification_id: qualification.id,
        )
    end

    def save_base
      return false unless valid?

      qualification = ApplicationQualification.find(qualification_id)

      qualification.update!(grade: grade, award_year: award_year)
    end
  end
end
