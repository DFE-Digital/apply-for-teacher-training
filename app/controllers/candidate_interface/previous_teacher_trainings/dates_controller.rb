module CandidateInterface
  module PreviousTeacherTrainings
    class DatesController < CandidateInterfaceController
      before_action :redirect_to_post_offer_dashboard_if_accepted_deferred_or_recruited
      before_action :set_previous_teacher_training
      before_action :set_back_path
      before_action :check_policy

      def new
        if @previous_teacher_training.published?
          @previous_teacher_training = @previous_teacher_training.create_draft_dup!
        end

        @form = DatesForm.new(@previous_teacher_training)
      end

      def create
        @form = DatesForm.new(@previous_teacher_training)
        @form.assign_attributes(request_params)

        if @form.save
          redirect_to @back_path || new_candidate_interface_previous_teacher_training_detail_path(
            @previous_teacher_training,
          )
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

      def request_params
        params.expect(
          candidate_interface_previous_teacher_trainings_dates_form: [
            'started_at(1i)',
            'started_at(2i)',
            'started_at(3i)',
            'ended_at(1i)',
            'ended_at(2i)',
            'ended_at(3i)',
          ],
        ).transform_keys { |key| start_date_field_to_attribute(key, 'started_at') }
        .transform_keys { |key| end_date_field_to_attribute(key, 'ended_at') }
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
