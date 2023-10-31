module ProviderInterface
  class DeclineOrWithdrawController < ProviderInterfaceController
    before_action :render_404_unless_feature_flag_active
    before_action :set_application_choice
    before_action :requires_make_decisions_permission
    before_action :redirect_to_application_choice_if_not_withdrawable_or_declinable

    def edit
      @interview_cancellation_presenter = InterviewCancellationExplanationPresenter.new(@application_choice)
    end

    def update
      service = DeclineOrWithdrawApplication.new(actor: current_provider_user, application_choice: @application_choice)

      if service.save!
        flash[:success] = 'Application withdrawn'
        redirect_to provider_interface_application_choice_path(@application_choice)
      else
        @interview_cancellation_presenter = InterviewCancellationExplanationPresenter.new(@application_choice)
        flash[:warning] = 'Could not withdraw application'
        render :edit
      end
    end

  private

    def render_404_unless_feature_flag_active
      render_404 unless FeatureFlag.active?(:withdraw_at_candidates_request)
    end

    def redirect_to_application_choice_if_not_withdrawable_or_declinable
      return if withdrawable_or_declinable?

      redirect_to provider_interface_application_choice_path(@application_choice)
    end

    def withdrawable_or_declinable?
      @application_choice.offer? || ApplicationStateChange.new(@application_choice).can_withdraw?
    end
  end
end
