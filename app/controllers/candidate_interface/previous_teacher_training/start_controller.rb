module CandidateInterface
  module PreviousTeacherTraining
    class StartController < CandidateInterfaceController
      before_action :redirect_to_post_offer_dashboard_if_accepted_deferred_or_recruited

      def new
        @form = ::PreviousTeacherTraining::Start.find_or_initialize_by(
          application_form: current_application,
        )
      end

      def create
        @form = ::PreviousTeacherTraining::Start.find_or_initialize_by(
          application_form: current_application,
        )
        @form.assign_attributes(form_params)

        render :new unless @form.save

        if @form.choice_yes?
          redirect_to @form.back_path(params) || edit_candidate_interface_previous_teacher_training_names_path
        elsif @form.choice_no?
          redirect_to @form.back_path(params) || candidate_interface_previous_teacher_training_review_path
        end
      end

    private

      def form_params
        request_params.merge(application_form_id: current_application.id)
      end

      def request_params
        params.expect(previous_teacher_training_start: [:choice])
      end
    end
  end
end
