class SubmitApplication
  attr_reader :application_form, :application_choices

  def initialize(application_form)
    @application_form = application_form
    @application_choices = application_form.application_choices
  end

  def call
    application_form.update!(submitted_at: Time.zone.now)

    application_choices.includes(%i[course_option current_course_option provider accredited_provider]).each do |application_choice|
      SendApplicationToProvider.call(application_choice)
    end

    # Cancel any outstanding references
    if FeatureFlag.active?(:reference_selection)
      application_form.application_references.feedback_requested.each do |reference|
        CancelReferee.new.call(reference: reference)
      end
    end

    if application_form.apply_2?
      CandidateMailer.application_submitted_apply_again(application_form).deliver_later
    else
      CandidateMailer.application_submitted(application_form).deliver_later
    end
  end
end
