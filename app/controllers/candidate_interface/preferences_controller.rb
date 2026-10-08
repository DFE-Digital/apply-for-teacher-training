module CandidateInterface
  class PreferencesController < CandidateInterfaceController
    before_action :assign_wizard
    before_action :clear_wizard
    before_action :assign_location_preference_attributes

    def new; end

    def create
      if @wizard.save_current_step
        redirect_to @wizard.next_step_path
      else
        @step = @wizard.current_step
        render :new
      end
    end

    private

    def assign_wizard
      @wizard = CandidateInterface::PreferencesWizard.new(
        current_step: params[:step]&.to_sym || :opt_in,
        current_step_params: params,
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
      @key ||= if false
                 "candidate_interface_preferences_wizard_#{current_application.id}_edit"
               else
                 "candidate_interface_preferences_wizard_#{current_application.id}_new"
               end.to_sym
    end

    def clear_wizard
      return unless @wizard.current_step_name == :opt_in

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
  end
end
