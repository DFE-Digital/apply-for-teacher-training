module VendorAPI
  class DecisionsController < VendorAPIController
    include ApplicationDataConcerns

    def make_offer
      validate_course_is_in_current_recruitment_cycle!

      respond_to_decision(offer_service_for(application_choice, course_option))
    end

    def confirm_conditions_met
      decision = ConfirmOfferConditions.new(
        actor: audit_user,
        application_choice:,
      )

      respond_to_decision(decision)
    end

    def conditions_not_met
      decision = ConditionsNotMet.new(
        actor: audit_user,
        application_choice:,
      )

      respond_to_decision(decision)
    end

    def reject
      reason = decision_params.fetch(:reason, nil)

      decision =
        if application_choice.offer?
          WithdrawOffer.new(
            actor: audit_user,
            application_choice:,
            offer_withdrawal_reason: reason,
          )
        else
          RejectApplication.new(
            actor: audit_user,
            application_choice:,
            rejection_reason: reason,
          )
        end

      respond_to_decision(decision)
    end

    def reject_by_codes
      decision = RejectApplication.new(
        actor: audit_user,
        application_choice:,
        structured_rejection_reasons: rejection_reasons,
      )
      respond_to_decision(decision)
    end

    # This method is a no-op since we removed enrolment from the app
    def confirm_enrolment
      render_application

      e = Exception.new("Vendor API token ##{@current_vendor_api_token.id} tried to enrol application choice ##{application_choice.id}, but enrolment is not supported")
      Sentry.capture_exception(e)
    end

  private

    def decision_params
      params.expect(data: [:reason])
    end

    def rejection_reasons
      raise ValidationException, ['Please provide one or more valid rejection codes.'] if params[:data].blank?

      VendorAPI::RejectionReasons.new(params[:data])
    rescue RejectionReasonCodeNotFound
      raise ValidationException, ['Please provide valid rejection codes.']
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

    def offer_params(application_choice, course_option)
      update_conditions_service = SaveOfferConditionsFromText.new(application_choice:, conditions: conditions_params)
      {
        actor: audit_user,
        application_choice:,
        course_option:,
        update_conditions_service:,
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

    def offer_service_for(application_choice, course_option)
      if application_choice.offer?
        ChangeOffer.new(**offer_params(application_choice, course_option))
      else
        MakeOffer.new(**offer_params(application_choice, course_option))
      end
    end

    def validate_course_is_in_current_recruitment_cycle!
      if course_option.course.recruitment_cycle_year != current_year
        raise ValidationException, ["Course must be in #{current_year} recruitment cycle"]
      end
    end

    def current_year
      @current_year ||= RecruitmentCycleTimetable.current_year
    end
  end
end
