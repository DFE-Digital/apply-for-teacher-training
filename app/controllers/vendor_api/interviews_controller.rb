module VendorAPI
  class InterviewsController < VendorAPIController
    include ApplicationDataConcerns
    include APIValidationsAndErrorHandling

    def create
      CreateInterview.new(
        actor: audit_user,
        application_choice: application_choice,
        provider: provider_for_interview,
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
        provider: provider_for_interview,
        date_and_time: interview_params[:date_and_time],
        location: interview_params[:location],
        additional_details: interview_params[:additional_details],
      ).save!

      render_application
    end

    def cancel
      CancelInterview.new(
        actor: audit_user,
        application_choice: application_choice,
        interview: existing_interview,
        cancellation_reason: cancel_interview_params[:reason],
      ).save!

      render_application
    end

  private

    def provider_for_interview
      Provider.find_by(code: interview_params[:provider_code])
    end

    def existing_interview
      application_choice.interviews.find params[:interview_id]
    end

    def interview_params
      params.require(:data).permit(
        :provider_code,
        :date_and_time,
        :location,
        :additional_details,
      ) || {}
    end

    def cancel_interview_params
      params.require(:data).permit(
        :reason,
      ) || {}
    end
  end
end
