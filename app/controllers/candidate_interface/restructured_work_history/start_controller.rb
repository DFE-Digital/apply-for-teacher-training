module CandidateInterface
  class RestructuredWorkHistory::StartController < RestructuredWorkHistory::BaseController
    def choice
      @choice_form = RestructuredWorkHistory::ChoiceForm.build_from_application(current_application)
    end

    def submit_choice
      @choice_form = RestructuredWorkHistory::ChoiceForm.new(choice_params)

      if @choice_form.save(current_application)
        redirect_to candidate_interface_restructured_work_history_review_path
      else
        track_validation_error(@choice_form)
        render :choice
      end
    end

  private

    def choice_params
      strip_whitespace(
        {
          choice: params.dig(:candidate_interface_restructured_work_history_choice_form, :choice),
          explanation: params.dig(:candidate_interface_restructured_work_history_choice_form, :explanation),
        },
      )
    end
  end
end
