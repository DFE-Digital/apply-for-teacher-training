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
          if @form.immigration_right_to_work == false
            redirect_to candidate_interface_immigration_route_path
          else
            redirect_to candidate_interface_immigration_route_path
          end
        else
          track_validation_error(@form)
          render :new
        end
      end

      # def edit
      #   @form = RightToWorkOrStudyForm.build_from_application(current_application)
      #   @return_to = return_to_after_edit(default: candidate_interface_personal_details_complete_path)
      # end

      # def update
      #   @form = RightToWorkOrStudyForm.new(right_to_work_params)
      #   @return_to = return_to_after_edit(default: candidate_interface_personal_details_complete_path)

      #   if @form.save(current_application)
      #     return redirect_to candidate_interface_application_review_path if redirect_back_to_application_review_page?

      #     redirect_to candidate_interface_personal_details_show_path
      #   else
      #     track_validation_error(@form)
      #     render :edit
      #   end
      # end

    private

      def right_to_work_params
        strip_whitespace params.require(:candidate_interface_immigration_right_to_work_form).permit(
          :immigration_right_to_work,
        )
      end
    end
  end
end
