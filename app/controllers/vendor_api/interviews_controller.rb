module VendorAPI
  class InterviewsController < VendorAPIController
    include ApplicationDataConcerns

    rescue_from InterviewWorkflowConstraints::WorkflowError, with: :handle_as_validation_error

    def create
      if version_number.to_f >= 1.7 && interview_params.blank?
        ApplicationStateChange.new(application_choice).interview!
      else
        CreateInterview.new(
          actor: audit_user,
          application_choice:,
          provider: provider_for_interview(interview_params[:provider_code]),
          date_and_time: date_and_time(interview_params[:date_and_time]),
          location: interview_params[:location],
          additional_details: interview_params[:additional_details],
        ).save!
      end

      render_application
    end

    def update
      UpdateInterview.new(
        actor: audit_user,
        interview: existing_interview,
        provider: provider_for_interview(update_interview_params[:provider_code]),
        date_and_time: date_and_time(update_interview_params[:date_and_time]),
        location: update_interview_params[:location],
        additional_details: update_interview_params[:additional_details],
      ).save!

      render_application
    end

    def cancel
      CancelInterview.new(
        actor: audit_user,
        application_choice:,
        interview: existing_interview,
        cancellation_reason: cancel_interview_reason,
      ).save!

      render_application
    end

  private

    def handle_as_validation_error(e)
      render status: :unprocessable_entity,
             json: { errors: [{ error: 'UnprocessableEntityResponse', message: e.message }] }
    end

    def provider_for_interview(code)
      if code.present? # supporting partial updates
        Provider.find_by(code:) || raise(ValidationException, ['Provider code is not valid'])
      end
    end

    def date_and_time(date_time_string)
      DateTime.parse(date_time_string) if date_time_string.present? # supporting partial updates
    rescue Date::Error
      raise ValidationException, ['Date string provided is not a valid date']
    end

    def existing_interview
      application_choice.interviews.find(interview_id)
    end

    def interview_id
      params.permit(:interview_id)[:interview_id]
    end

    def interview_params
      return {} if params[:data].blank?

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
