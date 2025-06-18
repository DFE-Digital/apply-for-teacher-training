class Candidate::InterviewPreview < ActionMailer::Preview
  def new_interview
    application_choice = FactoryBot.build_stubbed(:application_choice, :interviewing)
    interview = FactoryBot.build_stubbed(:interview, provider: application_choice.current_course_option.course.provider)
    CandidateMailer.new_interview(application_choice, interview)
  end

  def interview_updated
    application_choice = FactoryBot.build_stubbed(:application_choice, :interviewing, application_form: application_form)
    interview = FactoryBot.build_stubbed(:interview, provider: application_choice.current_course_option.course.provider)
    previous_course = nil
    CandidateMailer.interview_updated(application_choice, interview, previous_course)
  end

  def interview_updated_course_changed
    application_choice = FactoryBot.build_stubbed(:application_choice, :interviewing, application_form: application_form)
    interview = FactoryBot.build_stubbed(:interview, provider: application_choice.current_course_option.course.provider)
    previous_course = FactoryBot.build_stubbed(:course)
    CandidateMailer.interview_updated(application_choice, interview, previous_course)
  end

  def interview_cancelled
    application_choice = FactoryBot.build_stubbed(:application_choice, :interviewing)
    interview = FactoryBot.build_stubbed(:interview, provider: application_choice.current_course_option.course.provider)
    CandidateMailer.interview_cancelled(application_choice, interview, 'You contacted us to say you didn’t want to apply for this course any more.')
  end

private

  def candidate
    @candidate ||= FactoryBot.build_stubbed(:candidate)
  end

  def application_form
    @application_form ||= FactoryBot.build_stubbed(:application_form, first_name: 'Gemma', candidate:)
  end
end
