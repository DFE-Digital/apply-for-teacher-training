module CandidateInterface
  module PreviousTeacherTrainings
    class ReviewController < CandidateInterfaceController
      before_action :redirect_to_post_offer_dashboard_if_accepted_deferred_or_recruited
      before_action :set_previous_teacher_training, except: %i[index complete]
      before_action :set_section_policy
      before_action :check_policy, except: %i[index]

      def index
        @application_form = current_application
        @previous_teacher_trainings = @application_form.previous_teacher_trainings.published.order(:started_at, :ended_at)
        if @previous_teacher_trainings.exists?
          @form = PreviousTeacherTrainings::ReviewForm.new(@application_form)
        else
          redirect_to start_candidate_interface_previous_teacher_trainings_path
        end
      end

      def publish
        @previous_teacher_training.make_published

        redirect_to candidate_interface_previous_teacher_trainings_path
      end

      def complete
        @application_form = current_application
        @form = PreviousTeacherTrainings::ReviewForm.new(@application_form)
        @form.assign_attributes(request_params)

        if @form.save
          redirect_to candidate_interface_details_path
        else
          @previous_teacher_trainings = @application_form.previous_teacher_trainings.published.order(:started_at)
          render :index
        end
      end

      def remove; end

      def destroy
        if @previous_teacher_training.destroy
          flash[:success] = "Previous teacher training for #{@previous_teacher_training.provider_name} was deleted."
          if current_application.previous_teacher_trainings.published.none?
            current_application.update!(previous_teacher_training_completed: false)

            redirect_to start_candidate_interface_previous_teacher_trainings_path
          else
            redirect_to candidate_interface_previous_teacher_trainings_path
          end
        else
          flash[:error] = "Unable to delete the previous teacher training for #{@previous_teacher_training.provider_name}"
          redirect_to candidate_interface_previous_teacher_trainings_path
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

      def check_policy
        redirect_to candidate_interface_details_path unless @section_policy.can_edit?
      end
    end
  end
end
