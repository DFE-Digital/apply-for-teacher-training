module CandidateInterface
  module PreviousTeacherTraining
    class DetailsController < CandidateInterfaceController
      before_action :redirect_to_post_offer_dashboard_if_accepted_deferred_or_recruited
      before_action :set_back_path, only: [:edit]

      def edit
        @form = ::PreviousTeacherTraining::Details.find_or_initialize_by(
          application_form: current_application,
        )
      end

      def update
        @form = ::PreviousTeacherTraining::Details.find_or_initialize_by(
          application_form: current_application,
        )

        if @form.update(request_params)
          redirect_to candidate_interface_previous_teacher_training_review_path
        else
          render :edit
        end
      end

    private

      def request_params
        params.expect(
          previous_teacher_training_details: %i[details return_to],
        )
      end

      def set_back_path
        if params[:return_to] == 'review'
          @back_path = candidate_interface_previous_teacher_training_review_path
        end
      end
    end
  end
end
