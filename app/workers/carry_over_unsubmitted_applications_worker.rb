class CarryOverUnsubmittedApplicationsWorker
  include Sidekiq::Worker

  def perform
    unsubmitted_applications_from_earlier_cycle.each do |application_form|
      CarryOverApplication.new(application_form).call
    end
  end

private

  def unsubmitted_applications_from_earlier_cycle
    # TODO: Remove hard-coded year
    # TODO: Omit applications that have already been carried over (have a subsequent_application_form)
    ApplicationForm.joins(application_choices: :course).where(submitted_at: nil).where('courses.recruitment_cycle_year' => 2020).distinct
  end
end
