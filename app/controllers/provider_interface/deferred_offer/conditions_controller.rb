class ProviderInterface::DeferredOffer::ConditionsController < ProviderInterface::ProviderInterfaceController
  include ProviderInterface::DeferredOffer::Navigation

  def edit
    @conditions_form = DeferredOfferConfirmation::ConditionsForm.find_or_initialize_by(
      provider_user: current_provider_user,
      offer:,
    )
  end

  def update
    @conditions_form = DeferredOfferConfirmation::ConditionsForm.find_or_initialize_by(
      provider_user: current_provider_user,
      offer:,
    )

    if @conditions_form.update(conditions_form_params)
      ConfirmDeferredOffer.new(actor: current_provider_user,
                               application_choice:,
                               course_option:,
                               conditions_met: @conditions_form.offer_conditions_status).save
      redirect_to provider_interface_application_choice_path(application_choice)
    else
      render :edit, status: :unprocessable_entity
    end
  end

private

  def course_option
    provider.course_options.find_by(study_mode:, course:, site:)
  end

  def course
    Course.find(deferred_offer_confirmation.course_id)
  end

  def site
    Site.find(deferred_offer_confirmation.site_id)
  end

  def study_mode
    deferred_offer_confirmation.study_mode
  end

  def recruitment_cycle_year
    course.recruitment_cycle_year
  end

  def deferred_offer_confirmation
    DeferredOfferConfirmation.find_or_initialize_by(
      provider_user: current_provider_user,
      offer:,
    )
  end

  def conditions_form_params
    params.expect(deferred_offer_confirmation_conditions_form: [:conditions_status])
  end
end
