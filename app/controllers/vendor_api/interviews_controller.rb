module VendorAPI
  class InterviewsController < VendorAPIController
    include ApplicationDataConcerns
    include APIValidationsAndErrorHandling

    rescue_from InterviewWorkflowConstraints::WorkflowError, with: :render_workflow_error
    rescue_from NotModifiedError, with: :render_not_modified

    def create
      CreateInterview.new(
        actor: audit_user,
        application_choice: application_choice,
        provider: provider_for_interview(interview_params[:provider_code]),
        date_and_time: interview_params[:date_and_time],
        location: interview_params[:location],
        additional_details: interview_params[:additional_details],
      ).save!

      render_application
    end

    def update
      UpdateInterview.new(
        actor: audit_user,
        interview: existing_interview,
        provider: provider_for_interview(update_interview_params[:provider_code]),
        date_and_time: update_interview_params[:date_and_time],
        location: update_interview_params[:location],
        additional_details: update_interview_params[:additional_details],
      ).save!

      render_application
    end

    def cancel
      CancelInterview.new(
        actor: audit_user,
        application_choice: application_choice,
        interview: existing_interview,
        cancellation_reason: cancel_interview_reason,
      ).save!

      render_application
    end

  private

    def render_workflow_error(e)
      render status: :unprocessable_entity, json: {
        errors: [
          {
            error: 'WorkflowError',
            message: e.message,
          },
        ],
      }
    end

    def render_not_modified(e)
      render status: :unprocessable_entity, json: {
        errors: [
          {
            error: 'NotModifiedError',
            message: e.message,
          },
        ],
      }
    end

    def provider_for_interview(code)
      Provider.find_by(code: code)
    end

    def existing_interview
      application_choice.interviews.find(interview_id)
    end

    def interview_id
      params.permit(:interview_id)[:interview_id]
    end

    def interview_params
      params.require(:data).permit(:provider_code, :date_and_time, :location, :additional_details).tap do |data|
        data.require(%i[provider_code date_and_time location])
      end
    end

    def update_interview_params
      params.require(:data).permit(:provider_code, :date_and_time, :location, :additional_details)
    end

    def cancel_interview_reason
      params.require(:data).permit(:reason).tap do |data|
        data.require(:reason)
      end[:reason]
    end
  end
end
