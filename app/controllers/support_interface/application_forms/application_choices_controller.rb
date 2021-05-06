module SupportInterface
  module ApplicationForms
    class ApplicationChoicesController < SupportInterfaceController
      before_action :build_application_form, :build_application_choice
      before_action :redirect_to_application_form_unless_declined_and_reinstate_offer_flag_active, only: %i[confirm_reinstate_offer reinstate_offer]
      before_action :redirect_to_application_form_unless_accepted_and_change_offered_course_course_flag_active, except: %i[confirm_reinstate_offer reinstate_offer]

      def confirm_reinstate_offer
        @declined_course_choice = ReinstateDeclinedOfferForm.new
      end

      def reinstate_offer
        @declined_course_choice = ReinstateDeclinedOfferForm.new(reinstate_offer_params)

        if @declined_course_choice.save(@application_choice)
          flash[:success] = 'Offer was reinstated'
          redirect_to support_interface_application_form_path(@application_form.id)
        else
          render :confirm_reinstate_offer
        end
      end

      def change_offered_course_search
        @course_search = CourseSearchForm.new
      end

      def search
        @course_search = CourseSearchForm.new(
          application_form_id: @application_form.id,
          course_code: course_search_params[:course_code],
        )

        if @course_search.valid?
          redirect_to support_interface_application_form_choose_offered_course_option_path(
            course_code: course_search_params[:course_code],
            application_form_id: @application_form.id,
            application_choice_id: @application_choice.id,
          )
        else
          render :change_offered_course_search
        end
      end

      def choose_offered_course; end

    private

      def reinstate_offer_params
        params.require(:support_interface_application_forms_reinstate_declined_offer_form).permit(:status, :audit_comment_ticket, :accept_guidance)
      end

      def course_search_params
        params.require(:support_interface_application_forms_course_search_form)
              .permit(:course_code)
      end

      def build_application_form
        @application_form = ApplicationForm.find(params[:application_form_id])
      end

      def build_application_choice
        @application_choice = @application_form.application_choices.find(params[:application_choice_id])
      end

      def redirect_to_application_form_unless_declined_and_reinstate_offer_flag_active
        redirect_to support_interface_application_form_path(@application_form.id) unless FeatureFlag.active?(:support_user_reinstate_offer) && @application_choice.declined?
      end

      def redirect_to_application_form_unless_accepted_and_change_offered_course_course_flag_active
        redirect_to support_interface_application_form_path(@application_form.id) unless FeatureFlag.active?(:support_user_change_offered_course) && @application_choice.pending_conditions?
      end
    end
  end
end
