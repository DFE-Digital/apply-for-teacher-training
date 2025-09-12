module CandidateInterface
  module PreviousTeacherTraining
    class ReviewController < CandidateInterfaceController
      before_action :redirect_to_post_offer_dashboard_if_accepted_deferred_or_recruited
      before_action :set_form
      before_action :set_section_policy

      def show
        @form.completed = @form.application_form.previous_teacher_training_completed
      end

      def create
        @form.assign_attributes(request_params)

        if @form.save
          redirect_to application_form_path
        else
          render :show
        end
      end

    private

      def set_form
        return @form if defined?(@from)

        @form = ::PreviousTeacherTraining::Review.find_by(
          application_form: current_application,
        )

        if @form.nil?
          @form = ::PreviousTeacherTraining.find_by(
            application_form: current_application,
          ).build_review_form
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
        params.expect(previous_teacher_training_review: [:completed])
      end
    end
  end
end
