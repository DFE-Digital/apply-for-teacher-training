module CandidateInterface
  class PreferencesController < CandidateInterfaceController
    before_action :assign_wizard
    before_action :clear_wizard
    before_action :assign_location_preference_attributes

    def new; end

    def create
      if @wizard.save_current_step
        assign_flash
        redirect_to @wizard.next_step_path
      else
        @step = @wizard.current_step
        render :new
      end
    end

    def edit
      step = params[:step]
      state_store.write(preference_as_hash) if preference.present?
      step ||= preference.present? ? :publish : :opt_in

      redirect_to candidate_interface_new_preferences_path(step:)
    end

    private

    def step_params
      params
    end

    def assign_flash
      if @wizard.current_step_name == :opt_in && @wizard.opt_out?
        flash[:success] = "You are not sharing your application details with providers you have not applied to"
      elsif @wizard.current_step_name == :publish && current_application.notifications.pool_opt_in.any?
        flash[:success] = "You have updated your application sharing preferences"
      end
    end

    def preference
      @preference ||= current_application.published_preference
    end

    def update_params
      ActionController::Parameters.new(
        {
          current_step => preference_as_hash,
        },
      )
    end

    def preference_as_hash
      {
        preference_id: preference.id,
        dynamic_location_preferences: params.dig(current_step, :dynamic_location_preferences) || preference.dynamic_location_preferences,
        funding_type: params.dig(current_step, :funding_type) || preference.funding_type,
        opt_out_reason: params.dig(current_step, :opt_out_reason) || preference.opt_out_reason,
        pool_status: params.dig(current_step, :pool_status) || preference.pool_status,
        training_locations: params.dig(current_step, :training_locations) || preference.training_locations,
        location_preference_list: format_location_preferences,
      }
    end

    def current_step
      @current_step ||= params[:step]&.to_sym || :opt_in
    end

    def assign_wizard
      @wizard = CandidateInterface::PreferencesWizard.new(
        current_step:,
        current_step_params: step_params,
        state_store:,
      ).tap do |wizard|
        wizard.current_application = current_application
      end
    end

    def state_store
      @state_store ||= CandidateInterface::StateStores::PreferencesWizardStore.new(
        repository: DfE::Wizard::Repository::Cache.new(
          cache: Rails.cache,
          key:,
          expires_in: 7.days,
        ),
      ).tap do |store|
        store.write(current_application_id: current_application.id)
      end
    end

    def key
      @key ||= if preference.present?
                 "candidate_interface_preferences_wizard_#{current_application.id}_#{preference.id}_edit"
               else
                 "candidate_interface_preferences_wizard_#{current_application.id}_new"
               end.to_sym
    end

    def clear_wizard
      return unless @wizard.current_step_name == :opt_in && preference.blank? || action_name == 'edit'

      @wizard&.clear_state
    end

    def assign_location_preference_attributes
      return unless @wizard.current_step_name.in?([:add_location_preference, :remove_location_preference]) &&
                    params[:uuid].present?

      location_preferences = state_store[:location_preference_list]
      return if location_preferences.blank?

      location_preference = location_preferences.find { |lp| lp[:uuid] == params[:uuid] }
      state_store.write(uuid: location_preference[:uuid], within: location_preference[:within], location_name: location_preference[:location_name])
    end

    def format_location_preferences
      preference.location_preferences.map do |lp|
        {
          uuid: lp.id.to_s,
          location_name: lp.name,
          within: lp.within,
        }
      end
    end
  end
end
