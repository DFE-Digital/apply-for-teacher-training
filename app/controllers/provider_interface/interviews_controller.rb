module ProviderInterface
  class InterviewsController < ProviderInterfaceController
    before_action :set_application_choice
    before_action :interview_flag_enabled?
    before_action :requires_make_decisions_permission

    def index
      @provider_can_respond = current_provider_user.authorisation.can_make_decisions?(
        application_choice: @application_choice,
        course_option_id: @application_choice.offered_option.id,
      )

      @interviews = @application_choice.interviews.kept.includes([:provider])
    end

    def new
      @interview_form = InterviewForm.new
    end

    def check
      @interview_form = InterviewForm.new(interview_params)

      render :new unless @interview_form.valid?
    end


    def create
      @interview_form = InterviewForm(interview_params)
      @interview_form.save

      redirect_to provider_interface_application_choice_path(@application_choice)
    end

    def cancel
      @interview = @application_choice.interviews.find(params[:id])
    end

    def review_cancel
      @interview = @application_choice.interviews.find(params[:id])
      @interview.cancellation_reason = cancellation_reason
    end

    def confirm_cancel
      @interview = @application_choice.interviews.find(params[:id])
      @interview.cancellation_reason = cancellation_reason

      CancelInterview.new(
        actor: current_provider_user,
        application_choice: @application_choice,
        interview: @interview,
        cancellation_reason: cancellation_reason,
      ).save!

      flash['success'] = 'Interview cancelled'
      redirect_to provider_interface_application_choice_path(@application_choice)
    end

  private

    def cancellation_reason
      params.require(:interview).permit(:cancellation_reason)[:cancellation_reason]
    end

    def interview_flag_enabled?
      unless FeatureFlag.active?(:interviews)
        fallback_path = provider_interface_application_choice_path(@application_choice)
        redirect_back(fallback_location: fallback_path)
      end
    end

    def make_decisions_permission_orgs
      @_make_decisions_permission_orgs ||= begin
        application_choice_providers = [@application_choice.provider, @application_choice.accredited_provider].compact
        current_user_providers = current_provider_user
          .provider_permissions.includes([:provider])
          .make_decisions
        .map(&:provider)

        current_user_providers.select { |provider| application_choice_providers.include?(provider)  }
      end
    end
    helper_method :make_decisions_permission_orgs

    def interview_params
      params
        .require(:provider_interface_interview_form)
        .permit(:'date(3i)', :'date(2i)', :'date(1i)', :time, :location, :additional_details)
        .transform_keys { |key| date_field_to_attribute(key) }
        .transform_values(&:strip)
        .merge(application_choice: @application_choice)
    end

    def date_field_to_attribute(key)
      case key
      when 'date(3i)' then 'day'
      when 'date(2i)' then 'month'
      when 'date(1i)' then 'year'
      else key
      end
    end
  end
end
