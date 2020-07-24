module CandidateInterface
  module PersonalDetails
    class NationalitiesController < CandidateInterfaceController
      before_action :redirect_to_dashboard_if_submitted

      def new
        @nationalities_form = if FeatureFlag.active?('international_personal_details')
                                NationalitiesForm.new
                              else
                                NationalitiesForm.build_from_application(current_application)
                              end
      end

      def create
        @application_form = current_application
        @nationalities_form = NationalitiesForm.new(nationalities_params)

        if @nationalities_form.save(current_application)
          current_application.update!(personal_details_completed: false)
          if FeatureFlag.active?('international_personal_details') && !british_or_irish?
            redirect_to candidate_interface_right_to_work_or_study_path
          else
            redirect_to candidate_interface_languages_path
          end
        else
          track_validation_error(@nationalities_form)
          render :new
        end
      end

      def edit
        @nationalities_form = NationalitiesForm.build_from_application(current_application)
      end

      def update
        @application_form = current_application
        @nationalities_form = NationalitiesForm.new(nationalities_params)

        if @nationalities_form.save(current_application)
          current_application.update!(personal_details_completed: false)
          if FeatureFlag.active?('international_personal_details') && !british_or_irish?
            redirect_to candidate_interface_edit_right_to_work_or_study_path
          else
            redirect_to candidate_interface_personal_details_show_path
          end
        else
          track_validation_error(@nationalities_form)
          render :edit
        end
      end

    private

      def nationalities_params
        params.require(:candidate_interface_nationalities_form).permit(
          :first_nationality, :second_nationality, :british, :irish, :other, :other_nationality1, :other_nationality2, :other_nationality3
        )
      end

      def british_or_irish?
        (NationalitiesForm::UK_AND_IRISH_NATIONALITIES & current_application.nationalities).present?
      end
    end
  end
end
