class PurgeTestApplications
  include Sidekiq::Worker

  def perform(*)
    candidates_to_purge.find_each do |candidate|
      candidate.application_forms.each do |application_form|
        application_form.application_choices.each(&:destroy)
        application_form.destroy
      end
      candidate.destroy
    end
  end

private

  def candidates_to_purge
    Candidate
      .includes(application_forms: [:application_choices])
      .where("email_address ilike '%@example.com'")
  end
end
