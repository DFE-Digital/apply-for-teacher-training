class ProviderInterface::DeferredOffer::CoursesController < ProviderInterface::ProviderInterfaceController
  include ProviderInterface::DeferredOffer::Navigation

  def edit
    @course_form = DeferredOfferConfirmation::CourseForm.find_or_initialize_by(
      provider_user: current_provider_user,
      offer:,
    )
  end

  def update
    @course_form = DeferredOfferConfirmation::CourseForm.find_or_initialize_by(
      provider_user: current_provider_user,
      offer:,
    )

    if @course_form.update(course_form_params)
      redirect_to next_step_path(@course_form)
    else
      render :edit, status: :unprocessable_entity
    end
  end

private

  def course_form_params
    params.expect(deferred_offer_confirmation_course_form: %i[course_id course_id_raw])
  end
end
