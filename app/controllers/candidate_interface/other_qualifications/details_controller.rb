module CandidateInterface
  class OtherQualifications::DetailsController < OtherQualifications::BaseController
    def new
      @wizard = wizard_for(current_step: :details)
      @wizard.qualification_type ||= get_qualification&.qualification_type
      @wizard.assign_attributes(
        @wizard.attributes_for_new_qualification(
          current_application.application_qualifications.other.order(:created_at),
        ),
      )
    end

    def create
      @wizard = wizard_for(other_qualification_params.merge(current_step: :details))

      if @wizard.valid?(:details)
        @wizard.clear_state!
        commit

        # TODO: use @wizard.next_step for this?
        if @wizard.choice == 'same_type'
          redirect_to candidate_interface_new_other_qualification_details_path(id: current_application.application_qualifications.last.id)
        elsif @wizard.choice == 'different_type'
          redirect_to candidate_interface_new_other_qualification_type_path
        else
          redirect_to candidate_interface_review_other_qualifications_path
        end
      else
        track_validation_error(@wizard)
        render :new
      end
    end

    def edit
      @qualification = OtherQualificationForm.build_from_qualification(current_qualification)
      @type = @qualification.set_type(current_qualification)
    end

    def update
      @qualification = OtherQualificationForm.new(other_qualification_params)

      if @qualification.update(current_qualification)
        current_application.update!(other_qualifications_completed: false)

        redirect_to candidate_interface_review_other_qualifications_path
      else
        track_validation_error(@qualification)
        @type = @qualification.set_type(current_qualification)

        render :edit
      end
    end

  private

    def commit(qualification_id: nil)
      application_qualification =
        if qualification_id
          ApplicationQualification.find(qualification_id)
        else
          current_application.application_qualifications.build(
            level: ApplicationQualification.levels[:other],
          )
        end

      application_qualification.assign_attributes(@wizard.attributes_for_persistence)
      application_qualification.save!
    end

    def wizard_for(options)
      options[:checking_answers] = true if params[:checking_answers] == 'true'
      OtherQualificationWizard.new(
        WizardStateStores::RedisStore.new(key: persistence_key_for_current_user),
        options,
      )
    end

    def persistence_key_for_current_user
      "candidate_user_other_qualification_wizard-#{current_candidate.id}"
    end

    def other_qualification_params
      if FeatureFlag.active?('international_other_qualifications')
        params.require(:candidate_interface_other_qualification_wizard).permit(
          :subject, :grade, :award_year, :choice, :institution_country
        ).merge!(id: params[:id],
                 qualification_type: current_qualification.qualification_type,
                 non_uk_qualification_type: current_qualification.non_uk_qualification_type,
                 other_uk_qualification_type: current_qualification.other_uk_qualification_type)
      else
        params.require(:candidate_interface_other_qualification_wizard).permit(
          :subject, :grade, :award_year, :choice, :institution_country,
          :other_uk_qualification_type, :non_uk_qualification_type
        ).merge!(
          id: params[:id],
          qualification_type: params.dig('candidate_interface_other_qualification_wizard', 'qualification_type') || get_qualification.qualification_type,
        )
      end
    end

    def get_qualification
      return nil unless params[:id]

      @get_qualification ||= current_application.application_qualifications.other.find(params[:id])
    end
  end
end
