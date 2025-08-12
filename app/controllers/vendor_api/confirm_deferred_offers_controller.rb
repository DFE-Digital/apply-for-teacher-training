module VendorAPI
  class ConfirmDeferredOffersController < VendorAPIController
    include ApplicationDataConcerns

    def create
      course_data = confirm_deferred_offer_params[:course]

      course_option =
        if course_data.present?
          new_course_option(course_data)
        else
          application_choice.current_course_option.in_next_cycle
        end

      ConfirmDeferredOffer.new(actor: audit_user,
                               application_choice:,
                               course_option: course_option,
                               conditions_met:).save!

      render_application
    end

  private

    def conditions_met
      confirm_deferred_offer_params[:conditions_met]
    end

    def new_course_option(course_data)
      CourseOption.joins(course: :provider, site: :provider).find_by!(
        study_mode: course_data[:study_mode],
        courses: {
          providers: { code: course_data[:provider_code] },
          code: course_data[:course_code],
          recruitment_cycle_year: course_data[:recruitment_cycle_year],
        },
        sites: {
          providers: { code: course_data[:provider_code] },
          code: course_data[:site_code],
        },
      )
    end

    def confirm_deferred_offer_params
      params.require(:data).permit(
        :conditions_met,
        course: %i[
          recruitment_cycle_year
          provider_code
          course_code
          site_code
          study_mode
          start_date
        ],
      ).tap do |data|
        data.require(:conditions_met)
      end
    end
  end
end
