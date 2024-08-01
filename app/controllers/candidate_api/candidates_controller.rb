module CandidateAPI
  class CandidatesController < ApplicationAPIController
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
        data: serializer.serialize(paginate(serializer.index_query(updated_since: updated_since_params))),
      }
    end

    def show
      serializer ||=
        if version_param == 'v1.3'
          CandidateAPI::Serializers::V13.new
        elsif version_param == 'v1.2'
          CandidateAPI::Serializers::V12.new
        else
          CandidateAPI::Serializers::V11.new
        end

      candidate = Candidate
                    .left_outer_joins(:application_forms)
                    .where(application_forms: { recruitment_cycle_year: RecruitmentCycle.current_year })
                    .or(Candidate.where('candidates.created_at > ? ', CycleTimetable.apply_deadline(RecruitmentCycle.previous_year)))
                    .includes(application_forms: :application_choices)
                    .find(params[:candidate_id].gsub(/^C/, ''))

      render json: {
        data: serializer.serialize([candidate]).first,
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
      pagy, paginated_records = pagy(scope, items: per_page, page:)
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
      @serializer ||=
        if version_param == 'v1.3'
          CandidateAPI::Serializers::V13.new
        elsif version_param == 'v1.2'
          CandidateAPI::Serializers::V12.new
        else
          CandidateAPI::Serializers::V11.new
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

    def version_param
      params[:api_version] || CandidateAPISpecification::CURRENT_VERSION
    end
  end
end
