module CandidateInterface
  module PreviousTeacherTrainings
    class ReviewController < CandidateInterfaceController
      before_action :redirect_to_post_offer_dashboard_if_accepted_deferred_or_recruited
      before_action :set_previous_teacher_training
      before_action :set_section_policy

      def show
        @form = PreviousTeacherTrainings::ReviewForm.new(@previous_teacher_training)
        @form.publish!
      end

      def update
        @form = ReviewForm.new(@previous_teacher_training)
        @form.assign_attributes(request_params)

        if @form.save
          redirect_to candidate_interface_details_path
        else
          render :show
        end
      end

    private

      def set_previous_teacher_training
        @previous_teacher_training = current_application.previous_teacher_trainings.find_by(
          id: params.require(:id),
        )

        if @previous_teacher_training.nil?
          redirect_to candidate_interface_details_path
        end
      end

      def set_section_policy
        @section_policy = SectionPolicy.new(
          current_application:,
          controller_path:,
          action_name:,
          params:,
        )
      end

      def request_params
        params.expect(
          candidate_interface_previous_teacher_trainings_review_form: [:completed],
        )
      end
    end
  end
end
