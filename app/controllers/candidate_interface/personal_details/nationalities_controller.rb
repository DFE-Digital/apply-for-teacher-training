module CandidateInterface
  module PersonalDetails
    class NationalitiesController < CandidateInterfaceController
      before_action :redirect_to_dashboard_if_submitted

      def new
        @nationalities_form = NationalitiesForm.new
      end

      def create
        @application_form = current_application
        @nationalities_form = NationalitiesForm.new(prepare_nationalities_params)

        if @nationalities_form.save(current_application)
          if !british_or_irish?
            redirect_to candidate_interface_right_to_work_or_study_path
          elsif LanguagesSectionPolicy.hide?(current_application)
            redirect_to candidate_interface_personal_details_show_path
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
        @return_to = return_to_after_edit(default: candidate_interface_personal_details_complete_path)
      end

      def update
        @application_form = current_application
        @nationalities_form = NationalitiesForm.new(prepare_nationalities_params)
        @return_to = return_to_after_edit(default: candidate_interface_personal_details_complete_path)

        if @nationalities_form.save(current_application)
          return redirect_to candidate_interface_application_review_path if redirect_back_to_application_review_page?
          return redirect_to candidate_interface_edit_right_to_work_or_study_path if !british_or_irish?

          redirect_to candidate_interface_personal_details_show_path
        else
          track_validation_error(@nationalities_form)
          render :edit
        end
      end

    private

      def prepare_nationalities_params
        nationalities_params
          .merge(nationalities_hash)
      end

      def nationalities_hash
        nationalities_options = nationalities_params[:nationalities]
        nationalities_options ? nationalities_options.reject(&:blank?).index_by(&:downcase) : {}
      end

      def nationalities_params
        strip_whitespace params
          .require(:candidate_interface_nationalities_form)
          .permit(
            :first_nationality, :second_nationality, :other_nationality1, :other_nationality2, :other_nationality3, nationalities: []
          )
      end

      def british_or_irish?
        (NationalitiesForm::UK_AND_IRISH_NATIONALITIES & current_application.nationalities).present?
      end
    end
  end
end
