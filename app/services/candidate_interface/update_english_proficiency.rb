module CandidateInterface
  class UpdateEnglishProficiency
    attr_reader :application_form, :qualification_status, :efl_qualification, :no_qualification_details

    def initialize(application_form, qualification_status:, efl_qualification: nil, no_qualification_details: nil)
      @application_form = application_form
      @qualification_status = qualification_status
      @efl_qualification = efl_qualification
      @no_qualification_details = no_qualification_details
    end

    def call
      ActiveRecord::Base.transaction do
        application_form.english_proficiency&.destroy!
        application_form.build_english_proficiency(qualification_status: qualification_status)

        if application_form.english_proficiency.has_qualification?
          persist_qualification
        else
          declare_no_qualification
        end
      end
    end

  private

    def declare_no_qualification
      application_form.english_proficiency.no_qualification_details = no_qualification_details
      application_form.save!
    end

    def persist_qualification
      application_form.english_proficiency.efl_qualification = efl_qualification
      application_form.save!
    end
  end
end
