module VendorAPI
  class ConfirmDeferredOffersController < VendorAPIController
    include ApplicationDataConcerns

    def create
      course_data = confirm_deferred_offer_params[:course]

      course_option =
        if course_data.present?
          CourseOption.find_through_api(course_data)
        else
          application_choice.current_course_option.in_next_cycle
        end

      ConfirmDeferredOffer.new(actor: audit_user,
                               application_choice:,
                               course_option:,
                               conditions_met:).save!

      render_application
    end

  private

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
