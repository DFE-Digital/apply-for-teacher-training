module CandidateInterface
  class UpdateEnglishProficiencies
    attr_reader :application_form, :qualification_statuses, :efl_qualification, :no_qualification_details,
                :english_proficiency, :persist, :publish

    def initialize(application_form:, qualification_statuses:, english_proficiency: nil, efl_qualification: nil, no_qualification_details: nil, persist: false, publish: false)
      @application_form = application_form
      @qualification_statuses = qualification_statuses
      @english_proficiency = english_proficiency
      @efl_qualification = efl_qualification
      @no_qualification_details = no_qualification_details
      @persist = persist
      @publish = publish
    end

    def call
      return unless FeatureFlag.active?(:application_form_has_many_english_proficiencies)

      ActiveRecord::Base.transaction do
        assign_qualification_status

        if !persist && (new_english_proficiency.no_qualification || new_english_proficiency.degree_taught_in_english)
          new_english_proficiency.no_qualification_details = no_qualification_details
        end

        if !persist && new_english_proficiency.has_qualification
          new_english_proficiency.efl_qualification = efl_qualification
        end

        if publish ||
           (new_english_proficiency.qualification_not_needed &&
             !(new_english_proficiency.has_qualification || new_english_proficiency.degree_taught_in_english))
          new_english_proficiency.publish!
        end

        new_english_proficiency.save!
        application_form.save!
      end
    end

    def new_english_proficiency
      @new_english_proficiency ||= if english_proficiency.nil?
                                     application_form.english_proficiencies.build
                                   elsif !english_proficiency.draft
                                     english_proficiency.dup
                                   else
                                     english_proficiency
                                   end
    end

  private

    def assign_qualification_status
      new_english_proficiency.has_qualification = qualification_statuses.include?('has_qualification')
      new_english_proficiency.no_qualification = qualification_statuses.include?('no_qualification')
      new_english_proficiency.degree_taught_in_english = qualification_statuses.include?('degree_taught_in_english')
      new_english_proficiency.qualification_not_needed = qualification_statuses.include?('qualification_not_needed')
    end
  end
end
