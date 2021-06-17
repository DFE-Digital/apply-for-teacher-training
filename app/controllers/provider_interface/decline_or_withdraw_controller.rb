module ProviderInterface
  class DeclineOrWithdrawController < ProviderInterfaceController
    before_action :render_404_unless_feature_flag_active
    before_action :set_application_choice
    before_action :requires_make_decisions_permission

    def edit; end

    def update
      service = DeclineOrWithdrawApplication.new(actor: current_provider_user, application_choice: @application_choice)

      if service.save!
        flash[:success] = 'Application withdrawn'
        redirect_to provider_interface_application_choice_path(@application_choice)
      else
        flash[:warning] = 'Could not withdraw application'
        render :edit
      end
    end

  private

    def render_404_unless_feature_flag_active
      render_404 unless FeatureFlag.active?(:withdraw_at_candidates_request)
    end
  end
end
