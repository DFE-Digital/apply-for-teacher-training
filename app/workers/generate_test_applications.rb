class GenerateTestApplications
  include Sidekiq::Worker

  def initialize
    @test_applications = TestApplications.new

    dev_support_user = ProviderUser.find_by_dfe_sign_in_uid 'dev-support'
    @courses_to_apply_to = dev_support_user.providers.map(&:courses).map(&:open_on_apply).flatten if dev_support_user
  end

  def perform
    raise 'You can\'t generate test data in production' if HostingEnvironment.production?

    create states: [:unsubmitted]
    create states: [:awaiting_references]
    create states: [:unsubmitted], course_full: true
    create states: [:awaiting_references], course_full: true
    create states: [:application_complete]
    create states: [:awaiting_provider_decision] * 3
    create states: [:offer] * 2
    create states: %i[offer rejected]
    create states: [:rejected] * 2
    create states: [:offer_withdrawn]
    create states: [:declined]
    create states: [:accepted]
    create states: [:accepted_no_conditions]
    create states: [:recruited]
    create states: [:conditions_not_met]
    create states: [:enrolled]
    create states: [:withdrawn]
    create states: [:awaiting_provider_decision], apply_again: true
  end

  def create(states:, apply_again: false, course_full: false)
    @test_applications.create_application(
      courses_to_apply_to: @courses_to_apply_to,
      states: states,
      apply_again: apply_again,
      course_full: course_full,
    )
  end
end
