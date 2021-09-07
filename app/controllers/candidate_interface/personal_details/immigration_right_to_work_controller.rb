module CandidateInterface
  module PersonalDetails
    class ImmigrationRightToWorkController < CandidateInterfaceController
      before_action :redirect_to_dashboard_if_submitted

      def new
        @form = ImmigrationRightToWorkForm.build_from_application(current_application)
      end

      def create
        @form = ImmigrationRightToWorkForm.new(right_to_work_params)

        if @form.save(current_application)
          if ActiveModel::Type::Boolean.new.cast(@form.immigration_right_to_work)
            redirect_to candidate_interface_immigration_status_path
          else
            redirect_to candidate_interface_immigration_route_path
          end
        else
          track_validation_error(@form)
          render :new
        end
      end

    private

      def right_to_work_params
        strip_whitespace params.require(:candidate_interface_immigration_right_to_work_form).permit(
          :immigration_right_to_work,
        )
      end
    end
  end
end
