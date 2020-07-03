module CandidateInterface
  module PersonalDetails
    class NationalitiesController < CandidateInterfaceController
      before_action :redirect_to_dashboard_if_submitted

      def new
        if Featureflag.active?('international_personal_details')
          @nationalities_form =  NationalitiesForm.new
        else
          @nationalities_form = NationalitiesForm.build_from_application(current_application)
        end 
      end

      def create
        @application_form = current_application
        @nationalities_form = NationalitiesForm.new(nationalities_params)

        if @nationalities_form.save(current_application)
          current_application.update!(personal_details_completed: false)

          redirect_to candidate_interface_languages_path
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

          redirect_to candidate_interface_personal_details_show_path
        else
          track_validation_error(@nationalities_form)
          render :edit
        end
      end

    private

      def nationalities_params
        params.require(:candidate_interface_nationalities_form).permit(
          :first_nationality, :second_nationality
        )
      end
    end
  end
end
