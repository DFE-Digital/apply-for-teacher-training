module CandidateInterface
  class RejectionFeedbackSurveyController < CandidateInterfaceController
    def new
      ProvideRejectionFeedback.new(application_choice_params, helpful_params).call
      redirect_to candidate_interface_application_choices_path
      flash[:success] = 'Feedback successfully provided'
    end

  private

    def application_choice_params
      ApplicationChoice.find(params[:application_choice])
    end

    def helpful_params
      ActiveModel::Type::Boolean.new.cast(params[:helpful])
    end
  end
end
