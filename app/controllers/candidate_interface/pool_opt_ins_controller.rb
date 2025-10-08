module CandidateInterface
  class PoolOptInsController < CandidateInterfaceController
    before_action :redirect_to_review_for_duplicate_preferences, only: :new
    before_action :set_preference, only: %i[edit update]
    before_action :set_back_path, only: %i[edit update]
    before_action :redirect_to_root_path_if_submitted_applications
    before_action :redirect_to_invites_page_if_preference_is_blank_or_opt_out, only: :show

    def show; end

    def new
      @back_path = if just_submitted?
                     candidate_interface_application_choices_path
                   else
                     candidate_interface_invites_path
                   end
      @submit_params = { submit_application: just_submitted? }.compact_blank
      @preference_form = PoolOptInsForm.new(current_candidate:)
    end

    def edit
      if @preference.published?
        @preference = @preference.create_draft_dup
      end

      @preference_form = PoolOptInsForm.build_from_preference(
        current_candidate:,
        preference: @preference,
      )
    end

    def create
      @preference_form = PoolOptInsForm.new(
        current_candidate:,
        params: request_params,
      )

      if @preference_form.save
        if @preference_form.preference.opt_in?
          redirect_to new_candidate_interface_draft_preference_training_location_path(
            @preference_form.preference,
          )
        else
          flash[:success] = t('.opt_out_message')
          PreferencesEmail.call(preference: @preference_form.preference)

          redirect_to candidate_interface_invites_path
        end
      else
        @back_path = if just_submitted?
                       candidate_interface_application_choices_path
                     else
                       candidate_interface_invites_path
                     end
        render :new
      end
    end

    def update
      @preference_form = PoolOptInsForm.new(
        current_candidate:,
        preference: @preference,
        params: request_params,
      )

      if @preference_form.save
        if @preference.reload.opt_in?
          redirect_to @back_path || new_candidate_interface_draft_preference_training_location_path(
            @preference_form.preference,
          )
        else
          flash[:success] = t('.opt_out_message')
          PreferencesEmail.call(preference: @preference)

          redirect_to candidate_interface_invites_path
        end
      else
        render :edit
      end
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
      @preference = current_candidate.preferences.find_by(id: params[:id])

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
