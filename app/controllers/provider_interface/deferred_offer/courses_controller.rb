class ProviderInterface::DeferredOffer::CoursesController < ProviderInterface::ProviderInterfaceController
  def edit
    @course_form = DeferredOfferConfirmation::CourseForm.find_or_initialize_by(
      provider_user: current_provider_user,
      offer: offer,
    )
  end

  def update
    @course_form = DeferredOfferConfirmation::CourseForm.find_or_initialize_by(
      provider_user: current_provider_user,
      offer: offer,
    )

    if @course_form.update(course_form_params)
      redirect_to provider_interface_deferred_offer_check_path(application_choice)
    else
      render :edit, status: :unprocessable_entity
    end
  end

private

  def course_form_params
    params.expect(deferred_offer_confirmation_course_form: [:course_id])
  end

  def offer
    application_choice.offer
  end

  def application_choice
    GetApplicationChoicesForProviders.call(
      providers: current_provider_user.providers,
    ).find(params.require(:application_choice_id))
  end
end
