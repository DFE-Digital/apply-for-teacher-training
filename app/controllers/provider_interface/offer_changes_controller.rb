module ProviderInterface
  class OfferChangesController < ProviderInterfaceController
    before_action :set_application_choice
    before_action :requires_provider_change_response_feature_flag
    before_action :set_change_offer_form

    def edit_provider
      @change_offer_form.step = :provider
      set_alternative_providers
    end

    def edit_course
      @change_offer_form.step = :course
      if @change_offer_form.valid?
        set_alternative_courses
      else
        render_providers
      end
    end

    def edit_course_option
      @change_offer_form.step = :course_option
      if @change_offer_form.valid?
        set_alternative_course_options
      else
        render_courses
      end
    end

    def confirm_update
      @change_offer_form.step = :confirm
      if @change_offer_form.valid?
        @future_application_choice = @application_choice.dup
        @future_application_choice.offered_course_option_id = @change_offer_form.course_option_id
      elsif @change_offer_form.errors[:provider_id].present?
        render_providers
      elsif @change_offer_form.errors[:course_id].present?
        render_courses
      else
        render_course_options
      end
    end

    def update
      @change_offer_form.step = :update
      if @change_offer_form.valid?
        ChangeOffer.new(
          actor: current_provider_user,
          application_choice: @application_choice,
          course_option_id: @change_offer_form.course_option_id,
        ).save
        redirect_to provider_interface_application_choice_path(@application_choice.id)
      else
        raise 'cannot update offer'
      end
    end

  private

    def render_providers
      set_alternative_providers
      render :edit_provider
    end

    def render_courses
      set_alternative_courses
      render :edit_course
    end

    def render_course_options
      set_alternative_course_options
      render :edit_course_option
    end

    def requires_provider_change_response_feature_flag
      raise unless FeatureFlag.active?('provider_change_response')
    end

    def set_application_choice
      @application_choice = GetApplicationChoicesForProviders.call(providers: current_provider_user.providers)
        .find(params[:application_choice_id])
    end

    def set_change_offer_form
      @change_offer_form = ProviderInterface::ChangeOfferForm.new application_choice: @application_choice,
                                                                  provider_id: (provider.id if allowed_provider?),
                                                                  course_id: course&.id,
                                                                  course_option_id: course_option&.id
    end

    def allowed_provider?
      current_provider_user.providers.include?(provider)
    end

    def provider
      requested_provider || current_provider
    end

    def current_provider
      @application_choice.offered_course.provider
    end

    def requested_provider
      provider_id = change_offer_params[:provider_id]
      Provider.find(provider_id) if provider_id.present?
    end

    def course
      requested_course || current_course
    end

    def current_course
      @application_choice.offered_course
    end

    def requested_course
      course_id = change_offer_params[:course_id]
      Course.find(course_id) if course_id.present?
    end

    def course_option
      requested_course_option || current_course_option
    end

    def current_course_option
      @application_choice.offered_option
    end

    def requested_course_option
      course_option_id = change_offer_params[:course_option_id]
      CourseOption.find(course_option_id) if course_option_id.present?
    end

    def set_alternative_providers
      @alternative_providers = current_provider_user.providers.order(:name)
    end

    def set_alternative_courses
      @alternative_courses = Course.where(
        open_on_apply: true,
        provider: provider,
        study_mode: study_mode_for_alternative_courses,
      ).order(:name)
    end

    def set_alternative_course_options
      current_option = @application_choice.offered_option
      @alternative_course_options = CourseOption.where(
        course: course,
        study_mode: current_option.study_mode, # preserving study_mode, for now
        # TODO: check vacancy_status, e.g. 'B'
      ).includes(:site).order('sites.name')
    end

    def study_mode_for_alternative_courses
      current_study_mode = @application_choice.offered_option.study_mode
      [current_study_mode, :full_time_or_part_time]
    end

    def change_offer_params
      begin
        params.require(:provider_interface_change_offer_form).permit(:provider_id, :course_id, :course_option_id)
      rescue ActionController::ParameterMissing
        {}
      end
    end
  end
end
