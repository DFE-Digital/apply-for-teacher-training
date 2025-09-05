module CandidateInterface
  module PreviousTeacherTraining
    class StartController < CandidateInterfaceController
      def new
        @form = PreviousTeacherTrainingForm::Start.new
      end

      def create
        if request_params[:choice] == 'yes'
          redirect_to new_candidate_interface_previous_teacher_training_names_path
        else
        end
      end

      def request_params
        params.expect(previous_teacher_training_form_start: [:choice])
      end
    end
  end
end
