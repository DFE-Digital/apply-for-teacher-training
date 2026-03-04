module CandidateInterface
  class UpdateEnglishProficiencies
    attr_reader :application_form, :qualification_statuses, :efl_qualification, :no_qualification_details, :persist

    def initialize(application_form, qualification_statuses:, efl_qualification: nil, no_qualification_details: nil, persist: false)
      @application_form = application_form
      @qualification_statuses = qualification_statuses
      @efl_qualification = efl_qualification
      @no_qualification_details = no_qualification_details
      @persist = persist
    end

    def call
      return unless FeatureFlag.active?(:application_form_has_many_english_proficiencies)

      ActiveRecord::Base.transaction do
        if qualification_statuses.include?('no_qualification')
          persisted_no_qualification_details = application_form.english_proficiencies.no_qualification.last&.no_qualification_details if persist
          application_form.english_proficiencies.destroy_all
          application_form.english_proficiencies.no_qualification.build(
            no_qualification_details: no_qualification_details || persisted_no_qualification_details
          )
        else
          application_form.english_proficiencies.no_qualification.destroy_all

          if qualification_statuses.include?('qualification_not_needed')
            application_form.english_proficiencies.qualification_not_needed.build unless application_form.english_proficiencies.qualification_not_needed.exists?
          else
            application_form.english_proficiencies.qualification_not_needed.destroy_all
          end

          if qualification_statuses.include?('degree_taught_in_english')
            persisted_no_qualification_details = application_form.english_proficiencies.degree_taught_in_english.last&.no_qualification_details if persist
            application_form.english_proficiencies.degree_taught_in_english.destroy_all
            application_form.english_proficiencies.degree_taught_in_english.build(
              no_qualification_details: no_qualification_details || persisted_no_qualification_details
            )
          else
            application_form.english_proficiencies.degree_taught_in_english.destroy_all
          end

          if efl_qualification.present?
            application_form.english_proficiencies.has_qualification.destroy_all
            application_form.english_proficiencies.has_qualification.build(
              efl_qualification:,
            )
          elsif qualification_statuses.include?('has_qualification')
            application_form.english_proficiencies.has_qualification.destroy_all
          end
        end

        application_form.save!
      end
    end

    def update_no_qualification_details!(english_proficiency:, no_qualification_details:)
      english_proficiency.update!(no_qualification_details)
    end
  end
end
