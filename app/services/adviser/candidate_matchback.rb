class Adviser::CandidateMatchback
  def initialize(application_form)
    @application_form = application_form
  end

  def teacher_training_adviser_sign_up
    @teacher_training_adviser_sign_up ||= begin
      Adviser::TeacherTrainingAdviserSignUpDecorator.new(matchback_candidate_response)
    rescue StandardError => e
      # A 404 not found is returned when the matchback is unsuccessful,
      # indicating that the candidate does not exist in the GiT API.
      raise unless e.respond_to?(:code) && e.code == 404

      # We will return an empty TeacherTrainingAdviserSignUpDecorator
      Adviser::TeacherTrainingAdviserSignUpDecorator.new({})
    end
  end

private

  attr_reader :application_form

  def matchback_candidate_response
    teacher_training_adviser_api.matchback_candidate(existing_candidate_request)
  end

  def teacher_training_adviser_api
    GetIntoTeachingApiClient::TeacherTrainingAdviserApi.new
  end

  def existing_candidate_request
    GetIntoTeachingApiClient::ExistingCandidateRequest.new({
      email: application_form.candidate.email_address,
      first_name: application_form.first_name,
      last_name: application_form.last_name,
      date_of_birth: application_form.date_of_birth,
    })
  end
end
