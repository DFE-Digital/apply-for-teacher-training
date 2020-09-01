class CarryOverUnsubmittedApplicationsWorker
  include Sidekiq::Worker

  def perform
    unsubmitted_applications_from_earlier_cycle.each do |application_form|
      CarryOverApplication.new(application_form).call
    end
  end

private

  def unsubmitted_applications_from_earlier_cycle
    ApplicationForm
      .joins(application_choices: :course)
      .where(submitted_at: nil)
      .where('courses.recruitment_cycle_year' => RecruitmentCycle.previous_year)
      .where(
        'application_forms.candidate_id NOT IN (:hidden_candidates)',
        hidden_candidates: Candidate.where(hide_in_reporting: true).select(:id),
      )
      .where(
        'application_forms.id NOT IN (:duplicated_applications)',
        duplicated_applications: ApplicationForm.where.not(previous_application_form_id: nil).select(:previous_application_form_id),
      )
      .distinct
  end
end
