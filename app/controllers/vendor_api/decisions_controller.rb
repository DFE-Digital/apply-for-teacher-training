module VendorAPI
  class DecisionsController < VendorAPIController
    VERSION = '1.0'.freeze

    before_action :validate_metadata!
    rescue_from ValidationException, with: :render_validation_error

    def make_offer
      validate_course_is_in_current_recruitment_cycle!

      respond_to_decision(offer_service_for(application_choice, course_option))
    end

    def confirm_conditions_met
      decision = ConfirmOfferConditions.new(
        actor: audit_user,
        application_choice: application_choice,
      )

      respond_to_decision(decision)
    end

    def conditions_not_met
      decision = ConditionsNotMet.new(
        actor: audit_user,
        application_choice: application_choice,
      )

      respond_to_decision(decision)
    end

    def reject
      decision =
        if application_choice.offer?
          WithdrawOffer.new(
            actor: audit_user,
            application_choice: application_choice,
            offer_withdrawal_reason: params.dig(:data, :reason),
          )
        else
          RejectApplication.new(
            actor: audit_user,
            application_choice: application_choice,
            rejection_reason: params.dig(:data, :reason),
          )
        end

      respond_to_decision(decision)
    end

    # This method is a no-op since we removed enrolment from the app
    def confirm_enrolment
      render_application

      e = Exception.new("Vendor API token ##{@current_vendor_api_token.id} tried to enrol application choice ##{application_choice.id}, but enrolment is not supported")
      Sentry.capture_exception(e)
    end

  private

    def application_choice
      @application_choice ||= GetApplicationChoicesForProviders.call(providers: [current_provider], vendor_api: true).find(params[:application_id])
    end

    def render_application
      render json: %({"data":#{ApplicationPresenter.new(version_number, application_choice).serialized_json}})
    end

    def respond_to_decision(decision)
      if [MakeOffer, ChangeOffer].include?(decision.class)
        decision.save!
        render_application
      elsif decision.save
        render_application
      else
        render_validation_errors(decision.errors)
      end
    rescue IdenticalOfferError
      render_application
    rescue Workflow::NoTransitionAllowed
      render status: :unprocessable_entity, json: {
        errors: [
          error: 'StateTransitionError',
          message: I18n.t('activerecord.errors.models.application_choice.attributes.status.invalid_transition'),
        ],
      }
    rescue ProviderAuthorisation::NotAuthorisedError => e
      render status: :unprocessable_entity, json: {
        errors: [
          {
            error: 'NotAuthorisedError',
            message: e.message,
          },
        ],
      }
    end

    # Takes errors from ActiveModel::Validations and render them in the API response
    def render_validation_errors(errors)
      error_responses = errors.full_messages.map { |message| { error: 'ValidationError', message: message } }
      render status: :unprocessable_entity, json: { errors: error_responses }
    end

    def offer_params(application_choice, course_option)
      update_conditions_service = SaveOfferConditionsFromText.new(application_choice: application_choice, conditions: conditions_params)
      {
        actor: audit_user,
        application_choice: application_choice,
        course_option: course_option,
        update_conditions_service: update_conditions_service,
      }
    end

    def conditions_params
      params.require(:data).permit(conditions: [])[:conditions] || []
    end

    def retrieve_course!(course_data)
      course_option_service = GetCourseOptionFromCodes.new(
        provider_code: course_data[:provider_code],
        course_code: course_data[:course_code],
        recruitment_cycle_year: course_data[:recruitment_cycle_year],
        study_mode: course_data[:study_mode],
        site_code: course_data[:site_code],
      )
      course_option = course_option_service.call
      return course_option if course_option

      raise ValidationException, course_option_service.errors.messages.values.flatten
    end

    def course_option
      course_data = params.dig(:data, :course)

      @course_option ||=
        if course_data.present?
          retrieve_course!(course_data) || raise_no_course_found!
        else
          application_choice.current_course_option
        end
    end

    def render_validation_error(e)
      render status: :unprocessable_entity, json: e.as_json
    end

    def offer_service_for(application_choice, course_option)
      if application_choice.offer?
        ChangeOffer.new(offer_params(application_choice, course_option))
      else
        MakeOffer.new(offer_params(application_choice, course_option))
      end
    end

    def validate_course_is_in_current_recruitment_cycle!
      if course_option.course.recruitment_cycle_year != RecruitmentCycle.current_year
        raise ValidationException, ["Course must be in #{RecruitmentCycle.current_year} recruitment cycle"]
      end
    end
  end
end
