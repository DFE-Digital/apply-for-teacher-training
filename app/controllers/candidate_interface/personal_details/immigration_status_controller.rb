module CandidateInterface
  module PersonalDetails
    class ImmigrationStatusController < CandidateInterfaceController
      before_action :redirect_to_details_if_submitted

      def new
        @form = ImmigrationStatusForm.build_from_application(current_application)
      end

      def edit
        @form = ImmigrationStatusForm.build_from_application(current_application)
      end

      def create
        @form = ImmigrationStatusForm.new(
          status_params.merge(nationalities: current_application.nationalities),
        )

        if @form.save(current_application)
          if current_application.temporary_immigration_status?
            redirect_to new_candidate_interface_visa_expiry_path
          else
            redirect_to candidate_interface_personal_details_show_path
          end
        else
          track_validation_error(@form)
          render :new
        end
      end

      def update
        @form = ImmigrationStatusForm.new(
          status_params.merge(nationalities: current_application.nationalities),
        )

        if @form.save(current_application)
          if current_application.temporary_immigration_status?
            redirect_to new_candidate_interface_visa_expiry_path
          else
            redirect_to candidate_interface_personal_details_show_path
          end
        else
          track_validation_error(@form)
          render :edit
        end
      end

    private

      def status_params
        strip_whitespace params.expect(
          candidate_interface_immigration_status_form: %i[immigration_status
                                                          right_to_work_or_study_details],
        )
      end
    end
  end
end
