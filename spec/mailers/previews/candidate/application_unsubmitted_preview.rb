class Candidate::ApplicationUnsubmittedPreview < ActionMailer::Preview
  def nudge_unsubmitted
    application_form = FactoryBot.create(:completed_application_form)
    CandidateMailer.nudge_unsubmitted(application_form)
  end

  def nudge_unsubmitted_with_incomplete_courses
    application_form = FactoryBot.create(:completed_application_form)
    CandidateMailer.nudge_unsubmitted_with_incomplete_courses(application_form)
  end

  def nudge_unsubmitted_with_incomplete_personal_statement
    application_form = FactoryBot.create(:completed_application_form)
    CandidateMailer.nudge_unsubmitted_with_incomplete_personal_statement(application_form)
  end

  def nudge_unsubmitted_with_incomplete_references
    application_form = FactoryBot.build_stubbed(
      :application_form,
      :minimum_info,
      first_name: 'Fred',
    )
    CandidateMailer.nudge_unsubmitted_with_incomplete_references(application_form)
  end
end
