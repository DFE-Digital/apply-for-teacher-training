module CandidateInterface
  module PreviousTeacherTrainings
    class NamesController < CandidateInterfaceController
      before_action :redirect_to_post_offer_dashboard_if_accepted_deferred_or_recruited
      before_action :previous_teacher_training
      before_action :set_back_path
      before_action :check_policy

      def new
        if @previous_teacher_training.published?
          @previous_teacher_training = @previous_teacher_training.create_draft_dup
        end

        @form = NamesForm.new(@previous_teacher_training)
      end

      def create
        @form = NamesForm.new(@previous_teacher_training)
        @form.assign_attributes(form_params)

        if @form.save
          redirect_to @back_path || new_candidate_interface_previous_teacher_training_date_path(
            @previous_teacher_training,
          )
        else
          render :new
        end
      end

    private

      def previous_teacher_training
        @previous_teacher_training = current_application.previous_teacher_trainings.find_by(
          id: params.require(:previous_teacher_training_id),
        )

        if @previous_teacher_training.blank?
          redirect_to candidate_interface_details_path
        end
      end

      def form_params
        { provider_name: request_params[:provider_name_raw] || request_params[:provider_name] }
      end

      def request_params
        strip_whitespace(
          params.expect(
            candidate_interface_previous_teacher_trainings_names_form: %i[
              provider_name_raw
              provider_name
            ],
          ),
        )
      end

      def set_back_path
        if params[:return_to] == 'review'
          @back_path = candidate_interface_previous_teacher_training_path(
            @previous_teacher_training,
          )
        end
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
