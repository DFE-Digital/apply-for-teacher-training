class DeleteTestApplications
  include Sidekiq::Worker

  def perform(*)
    raise 'You can only delete test applications in a test environment' unless DeleteTestApplications.can_run_in_this_environment?

    application_form_ids = candidates_to_purge.flat_map(&:application_forms).map(&:id)
    candidates_to_purge.delete_all
    delete_work_experiences(application_form_ids)
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

  def delete_work_experiences(ids)
    ApplicationExperience.where(experienceable_id: ids, experienceable_type: 'ApplicationForm').delete_all
    ApplicationWorkHistoryBreak.where(breakable_id: ids, breakable_type: 'ApplicationForm').delete_all
  end
end
