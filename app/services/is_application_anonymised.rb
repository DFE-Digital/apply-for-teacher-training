class IsApplicationAnonymised
  attr_reader :application_form

  def initialize(application_form:)
    @application_form = application_form
  end

  def call
    application_form.candidate.email_address.include?('deleted-application-') ||
      application_form.candidate.email_address.include?('deleted_on_user_request')
  end
end
