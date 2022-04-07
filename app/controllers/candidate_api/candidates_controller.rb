module CandidateAPI
  class CandidatesController < ActionController::API
    include ServiceAPIUserAuthentication
    include RemoveBrowserOnlyHeaders
    include Pagy::Backend

    rescue_from ActionController::ParameterMissing, with: :parameter_missing
    rescue_from ParameterInvalid, with: :parameter_invalid

    # Makes PG::QueryCanceled statement timeout errors appear in Skylight
    # against the controller action that triggered them
    # instead of bundling them with every other ErrorsController#internal_server_error
    rescue_from ActiveRecord::QueryCanceled, with: :statement_timeout

    rescue_from Pagy::OverflowError, with: :page_parameter_invalid
    rescue_from PerPageParameterInvalid, with: :per_page_parameter_invalid

    DEFAULT_PER_PAGE = 500
    MAX_PER_PAGE = 500

    def index
      render json: {
        data: serializer.serialize(paginate(serializer.query))
      }
    end

    def parameter_missing(e)
      error_message = e.message.split("\n").first
      render json: { errors: [{ error: 'ParameterMissing', message: error_message }] }, status: :unprocessable_entity
    end

    def parameter_invalid(e)
      render json: { errors: [{ error: 'ParameterInvalid', message: e }] }, status: :unprocessable_entity
    end

    def statement_timeout
      render json: {
        errors: [
          {
            error: 'InternalServerError',
            message: 'The server encountered an unexpected condition that prevented it from fulfilling the request',
          },
        ],
      }, status: :internal_server_error
    end

    def page_parameter_invalid(e)
      last_page = e.message.scan(/\d+/)[1]
      error_message = "expected 'page' parameter to be between 1 and #{last_page}, got #{params[:page]}"
      render json: { errors: [{ error: 'PageParameterInvalid', message: error_message }] }, status: :unprocessable_entity
    end

    def per_page_parameter_invalid
      render json: {
        errors: [
          {
            error: 'PerPageParameterInvalid',
            message: "the 'per_page' parameter cannot exceed #{MAX_PER_PAGE} results per page",
          },
        ],
      }, status: :unprocessable_entity
    end

  private

    def paginate(scope)
      pagy, paginated_records = pagy(scope, items: per_page, page: page)
      pagy_headers_merge(pagy)

      paginated_records
    end

    def per_page
      raise PerPageParameterInvalid unless params[:per_page].to_i <= MAX_PER_PAGE

      [(params[:per_page] || DEFAULT_PER_PAGE).to_i, MAX_PER_PAGE].min
    end

    def page
      (params[:page] || 1).to_i
    end

    def serializer
      if version_param == 'v1.2'
        V1_2.new(updated_since: updated_since_params)
      else
        V1_1.new(updated_since: updated_since_params)
      end
    end

    class V1_1
      attr_reader :updated_since

      def initialize(updated_since:)
        @updated_since = updated_since
      end

      def serialize(candidates)
        candidates.map do |candidate|
          {
            id: candidate.public_id,
            type: 'candidate',
            attributes: {
              created_at: candidate.created_at.iso8601,
              updated_at: candidate.candidate_api_updated_at,
              email_address: candidate.email_address,
              application_forms:
                candidate.application_forms.order(:created_at).map do |application|
                  {
                    id: application.id,
                    created_at: application.created_at.iso8601,
                    updated_at: application.updated_at.iso8601,
                    application_status: ProcessState.new(application).state,
                    application_phase: application.phase,
                    recruitment_cycle_year: application.recruitment_cycle_year,
                    submitted_at: application.submitted_at&.iso8601,
                  }
                end,
            },
          }
        end
      end

      def query
        Candidate
        .left_outer_joins(:application_forms)
        .where(application_forms: { recruitment_cycle_year: RecruitmentCycle.current_year })
        .or(Candidate.where('candidates.created_at > ? ', CycleTimetable.apply_1_deadline(RecruitmentCycle.previous_year)))
        .distinct
        .includes(application_forms: :application_choices)
        .where('candidate_api_updated_at > ?', updated_since)
        .order('candidates.candidate_api_updated_at DESC')
      end
    end

    class V1_2
      attr_reader :updated_since

      def initialize(updated_since:)
        @updated_since = updated_since
      end

      def serialize(candidates)
        candidates.map do |candidate|
          {
            id: candidate.public_id,
            type: 'candidate',
            attributes: {
              created_at: candidate.created_at.iso8601,
              updated_at: candidate.candidate_api_updated_at,
              email_address: candidate.email_address,
              application_forms:
                candidate.application_forms.order(:created_at).map do |application|
                  {
                    id: application.id,
                    created_at: application.created_at.iso8601,
                    updated_at: application.updated_at.iso8601,
                    application_status: ProcessState.new(application).state,
                    application_phase: application.phase,
                    recruitment_cycle_year: application.recruitment_cycle_year,
                    submitted_at: application.submitted_at&.iso8601,
                  }
                end,
            },
          }
        end
      end

      def query
        Candidate
        .left_outer_joins(:application_forms)
        .where(application_forms: { recruitment_cycle_year: RecruitmentCycle.current_year })
        .or(Candidate.where('candidates.created_at > ? ', CycleTimetable.apply_1_deadline(RecruitmentCycle.previous_year)))
        .distinct
        .includes(application_forms: :application_choices)
        .where('candidate_api_updated_at > ?', updated_since)
        .order('candidates.candidate_api_updated_at DESC')
      end
    end

    def paginate(scope)
      pagy, paginated_records = pagy(scope, items: per_page, page: page)
      pagy_headers_merge(pagy)

      paginated_records
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

    def version_param
      params[:api_version] || CandidateAPISpecification::CURRENT_VERSION
    end
  end
end
