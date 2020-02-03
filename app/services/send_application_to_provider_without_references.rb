class SendApplicationToProviderWithoutReferences
  attr_reader :application_form

  def initialize(application_form)
    @application_form = application_form
  end

  def call
    application_form.application_choices.includes([:course_option, :course, provider: [:provider_users, :provider_users_providers]]).each do |application_choice|
      SendApplicationToProvider.new(application_choice: application_choice).call
    end
  end
end
