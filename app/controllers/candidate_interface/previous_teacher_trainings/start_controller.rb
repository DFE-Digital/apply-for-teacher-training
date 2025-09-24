module CandidateInterface
  module PreviousTeacherTrainings
    class StartController < CandidateInterfaceController
      before_action :redirect_to_post_offer_dashboard_if_accepted_deferred_or_recruited
      before_action :set_previous_teacher_training, only: %i[edit update]
      before_action :check_policy

      def new
        @form = StartForm.new
      end

      def edit
        if @previous_teacher_training.published?
          @previous_teacher_training = @previous_teacher_training.create_draft_dup!
        end

        @form = StartForm.new(@previous_teacher_training)
      end

      def create
        @form = StartForm.new(current_application.previous_teacher_trainings.new)
        @form.assign_attributes(form_params)

        if @form.save
          redirect_to @form.next_path(params)
        else
          render :new
        end
      end

      def update
        @form = StartForm.new(@previous_teacher_training)
        @form.assign_attributes(form_params)

        if @form.save
          redirect_to @form.next_path(params)
        else
          render :new
        end
      end

    private

      def set_previous_teacher_training
        @previous_teacher_training = current_application.previous_teacher_trainings.find_by(
          id: params.require(:previous_teacher_training_id),
        )

        if @previous_teacher_training.blank?
          redirect_to candidate_interface_details_path
        end
      end

      def form_params
        { started: request_params[:started] }
      end

      def request_params
        params.expect(
          candidate_interface_previous_teacher_trainings_start_form: [:started],
        )
      end

      def check_policy
        section_policy = SectionPolicy.new(
          current_application:,
          controller_path:,
          action_name:,
          params:,
        )

        redirect_to candidate_interface_details_path unless section_policy.can_edit?
      end
    end
  end
end
