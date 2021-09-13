class DeleteTestApplications
  include Sidekiq::Worker
  include SafePerformAsync

  def perform(*)
    raise 'You can only delete test applications in a test environment' unless DeleteTestApplications.can_run_in_this_environment?

    candidates_to_purge.delete_all
  end

  def self.can_run_in_this_environment?
    HostingEnvironment.test_environment?
  end

private

  def candidates_to_purge
    Candidate
      .includes(application_forms: [:application_choices])
      .where("email_address ilike '%@example.com'")
  end
end
