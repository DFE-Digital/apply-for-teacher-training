module VendorAPI
  class ConfirmDeferredOffersController < VendorAPIController
    include ApplicationDataConcerns

    def create
      ConfirmDeferredOffer.new(actor: audit_user,
                               application_choice:,
                               course_option:,
                               conditions_met:).save!

      render_application
    end

  private

    def course_option
      if course_data.present?
        GetCourseOptionFromCodes.new(
          provider_code: course_data[:provider_code],
          course_code: course_data[:course_code],
          study_mode: course_data[:study_mode],
          site_code: course_data[:site_code],
          recruitment_cycle_year: course_data[:recruitment_cycle_year],
        ).call
      else
        application_choice.current_course_option.in_next_cycle
      end
    end

    def course_data
      confirm_deferred_offer_params[:course]
    end

    def conditions_met
      confirm_deferred_offer_params[:conditions_met]
    end

    def confirm_deferred_offer_params
      permitted = params.require(:data).permit(
        :conditions_met,
        course: %i[
          recruitment_cycle_year
          provider_code
          course_code
          site_code
          study_mode
          start_date
        ],
      )

      permitted.require(:conditions_met)
      permitted
    end
  end
end
