class PurgeTestApplications
  include Sidekiq::Worker

  def perform(*)
    application_forms_to_purge.find_each do |application_form|
      application_form.destroy
    end
  end

private

  def application_forms_to_purge
    ApplicationForm.joins(:candidate).where("candidates.email_address ilike '%@example.com'")
  end
end
