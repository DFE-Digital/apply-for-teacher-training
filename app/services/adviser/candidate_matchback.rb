class Adviser::CandidateMatchback
  attr_reader :application_form

  def initialize(application_form)
    @application_form = application_form
  end

  def matchback
    @matchback ||= begin
      api = GetIntoTeachingApiClient::TeacherTrainingAdviserApi.new
      response = api.matchback_candidate(existing_candidate_request)
      Adviser::APIModelDecorator.new(response)
    rescue StandardError => e
      #  A 404 not found is returned when the matchback is unsuccessful,
      # indicating that the candidate does not exist in the GiT API.
      raise unless e.respond_to?(:code) && e.code == 404

      nil
    end
  end

private

  def existing_candidate_request
    GetIntoTeachingApiClient::ExistingCandidateRequest.new({
      email: application_form.candidate.email_address,
      first_name: application_form.first_name,
      last_name: application_form.last_name,
      date_of_birth: application_form.date_of_birth,
    })
  end
end
