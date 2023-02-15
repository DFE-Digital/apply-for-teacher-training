module Adviser::Matchback
  extend ActiveSupport::Concern

private

  def matchback_candidate
    @matchback_candidate ||= begin
      api = GetIntoTeachingApiClient::TeacherTrainingAdviserApi.new
      api.matchback_candidate(existing_candidate_request)
    rescue GetIntoTeachingApiClient::ApiError => e
      #  A 404 not found is returned when the matchback is unsuccessful,
      # indicating that the candidate does not exist in the GiT API.
      raise unless e.code == 404

      nil
    end
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
