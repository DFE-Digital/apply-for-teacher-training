class Provider::ReferencesMailerPreview < ActionMailer::Preview
  include PreviewProviderHelper

  def reference_received
    reference = FactoryBot.create(:reference, :feedback_provided, application_form: application_choice.application_form)
    ProviderMailer.reference_received(reference:, application_choice:, provider_user:, course:)
  end

private

  def provider
    @provider ||= FactoryBot.create(:provider, code: unique_provider_code)
  end

  def site
    @site ||= FactoryBot.create(:site, code: '-', name: 'Main site', provider:)
  end

  def application_choice
    @application_choice ||= FactoryBot.create(
      :application_choice,
      :awaiting_provider_decision,
      course_option:,
      application_form: FactoryBot.create(:completed_application_form),
    )
  end

  def course
    @course ||= FactoryBot.create(:course, provider:)
  end

  def course_option
    @course_option ||= FactoryBot.create(:course_option, course:, site:)
  end

  def provider_user
    @provider_user ||= FactoryBot.build(:provider_user, providers: [provider])
  end
end
