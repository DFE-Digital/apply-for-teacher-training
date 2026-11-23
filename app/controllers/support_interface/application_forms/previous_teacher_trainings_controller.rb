module SupportInterface
  module ApplicationForms
    class PreviousTeacherTrainingsController < SupportInterfaceController
      include AuthorizeSupportUserCandidateEditable

      before_action :set_application_form

      def edit
        @previous_teacher_training = @application_form.previous_teacher_trainings.find(params[:id])
        @details_form = EditPreviousTeacherTrainingForm.build_from_previous_teacher_training(@previous_teacher_training)
      end

    private

      def set_application_form
        @application_form = ApplicationForm.find(params.expect(:application_form_id))
      end
    end
  end
end
