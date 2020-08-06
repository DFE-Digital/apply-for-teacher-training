class DeleteTestApplications
  include Sidekiq::Worker

  def perform(*)
    raise 'You can only delete test applications in a test environment' unless DeleteTestApplications.can_run_in_this_environment?

    candidates_to_purge.delete_all
  end

  TEST_ENVIRONMENTS = %w[development test qa review].freeze

  def self.can_run_in_this_environment?
    TEST_ENVIRONMENTS.include?(HostingEnvironment.environment_name)
  end

private

  def candidates_to_purge
    Candidate
      .includes(application_forms: [:application_choices])
      .where("email_address ilike '%@example.com'")
  end
end
