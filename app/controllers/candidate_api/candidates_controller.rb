module CandidateAPI
  class CandidatesController < ActionController::API
    include ServiceAPIUserAuthentication

    rescue_from ActionController::ParameterMissing, with: :parameter_missing
    rescue_from ParameterInvalid, with: :parameter_invalid

    # Makes PG::QueryCanceled statement timeout errors appear in Skylight
    # against the controller action that triggered them
    # instead of bundling them with every other ErrorsController#internal_server_error
    rescue_from ActiveRecord::QueryCanceled, with: :statement_timeout

    def index
      render json: { data: serialized_candidates }
    end

    def parameter_missing(e)
      error_message = e.message.split("\n").first
      render json: { errors: [{ error: 'ParameterMissing', message: error_message }] }, status: :unprocessable_entity
    end

    def parameter_invalid(e)
      render json: { errors: [{ error: 'ParameterInvalid', message: e }] }, status: :unprocessable_entity
    end

    def statement_timeout
      render json: { errors: [{ error: 'QueryCanceled', message: 'There is a problem with the service' }] }, status: :internal_server_error
    end

  private

    def serialized_candidates
      candidates = Candidate.includes(application_forms: :application_choices)
                            .where('candidate_api_updated_at > ?', updated_since_params)
                            .order('application_forms.created_at DESC')

      candidates.map do |candidate|
        {
          id: candidate.public_id,
          type: 'candidate',
          attributes: {
            email_address: candidate.email_address,
            created_at: candidate.created_at,
            updated_at: candidate.candidate_api_updated_at,
            application_forms: {
              data: [candidate.application_forms.map do |application|
                {
                  id: application.id,
                  created_at: application.created_at,
                  application_status: ProcessState.new(application).state,
                  application_phase: application.phase,
                }
              end],
            },
          },
        }
      end
    end

    def updated_since_params
      updated_since_value = params.require(:updated_since)

      begin
        date = Time.zone.iso8601(updated_since_value)
        raise ParameterInvalid, 'Parameter is invalid (date is nonsense): updated_since' unless date.year.positive?

        date
      rescue ArgumentError, KeyError
        raise ParameterInvalid, 'Parameter is invalid (should be ISO8601): updated_since'
      end
    end
  end
end
