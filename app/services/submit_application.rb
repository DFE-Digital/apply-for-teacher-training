class SubmitApplication
  attr_reader :application_form, :application_choices

  def initialize(application_form)
    @application_form = application_form
    @application_choices = application_form.application_choices
  end

  def call
    ActiveRecord::Base.transaction do
      application_form.update!(submitted_at: Time.zone.now)

      application_choices.includes(%i[original_course_option course_option current_course_option provider accredited_provider application_form candidate]).each do |application_choice|
        SendApplicationToProvider.call(application_choice)
      end
    end

    CandidateMailer.application_submitted(application_form).deliver_later
  end
end
