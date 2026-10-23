module CandidateInterface
  class PoolOptInsController < CandidateInterfaceController
    before_action :redirect_to_root_path_if_submitted_applications
    before_action :redirect_to_invites_page_if_preference_is_blank_or_opt_out, only: :show

    def show
      current_application.notifications.create(notification_type: 'pool_opt_in')
    end

  private

    def just_submitted?
      params[:submit_application] == 'true'
    end

    def request_params
      params.fetch(:candidate_interface_pool_opt_ins_form, {}).permit(
        :pool_status, :opt_out_reason
      )
    end

    def set_preference
      @preference = current_application.preferences.find_by(id: params[:id])

      if @preference.blank?
        redirect_to candidate_interface_invites_path
      end
    end

    def redirect_to_review_for_duplicate_preferences
      preference = current_application.duplicated_preferences.last
      if preference.present?
        redirect_to candidate_interface_draft_preference_path(preference, return_to: 'application-sharing')
      end
    end

    def set_back_path
      if params[:return_to] == 'review'
        @back_path = candidate_interface_draft_preference_path(@preference)
      end
    end

    def redirect_to_root_path_if_submitted_applications
      redirect_to root_path unless current_application.submitted_applications?
    end

    def redirect_to_invites_page_if_preference_is_blank_or_opt_out
      if current_application.published_preference.nil? || current_application.published_preference.opt_out?
        redirect_to candidate_interface_invites_path
      end
    end
  end
end
