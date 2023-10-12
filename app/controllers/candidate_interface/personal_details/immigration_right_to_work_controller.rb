module CandidateInterface
  module PersonalDetails
    class ImmigrationRightToWorkController < CandidateInterfaceController
      before_action :redirect_to_details_if_submitted

      def new
        @form = ImmigrationRightToWorkForm.build_from_application(current_application)
      end

      def edit
        @form = ImmigrationRightToWorkForm.build_from_application(current_application)
      end

      def create
        @form = ImmigrationRightToWorkForm.new(right_to_work_params)

        if @form.save(current_application)
          if @form.right_to_work_or_study?
            redirect_to candidate_interface_immigration_status_path
          else
            redirect_to candidate_interface_personal_details_show_path
          end
        else
          track_validation_error(@form)
          render :new
        end
      end

      def update
        @form = ImmigrationRightToWorkForm.new(right_to_work_params)

        if @form.save(current_application)
          if @form.right_to_work_or_study?
            redirect_to candidate_interface_immigration_status_path
          else
            redirect_to candidate_interface_personal_details_show_path
          end
        else
          track_validation_error(@form)
          render :edit
        end
      end

    private

      def right_to_work_params
        {
          right_to_work_or_study: params.dig(
            :candidate_interface_immigration_right_to_work_form,
            :right_to_work_or_study,
          ),
        }
      end
    end
  end
end
