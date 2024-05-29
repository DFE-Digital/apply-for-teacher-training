module DataAPI
  class TADDataExportsController < ApplicationAPIController
    include ServiceAPIUserAuthentication
    include RemoveBrowserOnlyHeaders

    rescue_from ParameterInvalid, with: :parameter_invalid
    rescue_from ActionController::ParameterMissing, with: :parameter_missing

    # Makes PG::QueryCanceled statement timeout errors appear in Skylight
    # against the controller action that triggered them
    # instead of bundling them with every other ErrorsController#internal_server_error
    rescue_from ActiveRecord::QueryCanceled, with: :statement_timeout

    def index
      formatted_exports = exports.map do |export|
        {
          export_date: export.completed_at,
          description: export.name,
          url: data_api_tad_export_url(export.id),
          updated_at: export.updated_at,
        }
      end

      render json: { data: formatted_exports.as_json }
    end

    def show
      data_export = DataAPI::TADExport.all.find(params[:id])
      serve_export(data_export)
    end

    def latest
      data_export = DataAPI::TADExport.latest
      serve_export(data_export)
    end

    def candidates
      all = DataExport
        .where(export_type: :ministerial_report_candidates_export)
        .where.not(completed_at: nil)

      data_export = all.last

      serve_export(data_export)
    end

    def applications
      all = DataExport
        .where(export_type: :ministerial_report_applications_export)
        .where.not(completed_at: nil)

      data_export = all.last

      serve_export(data_export)
    end

    def subject_domicile_nationality_latest
      data_export = DataExport
        .where(export_type: :tad_subject_domicile_nationality)
        .where.not(completed_at: nil)
        .last

      serve_export(data_export)
    end

    def applications_by_subject_route_and_degree_grade
      all = DataExport
      .where(export_type: :applications_by_subject_route_and_degree_grade)
      .where.not(completed_at: nil)

      data_export = all.last

      serve_export(data_export)
    end

    def applications_by_demographic_domicile_and_degree_class
      all = DataExport.where(export_type: :applications_by_demographic_domicile_and_degree_class).where.not(completed_at: nil)

      data_export = all.last

      serve_export(data_export)
    end

    def parameter_invalid(e)
      render json: { errors: [{ error: 'ParameterInvalid', message: e }] }, status: :unprocessable_entity
    end

    def parameter_missing(e)
      error_message = e.message.split("\n").first
      render json: { errors: [{ error: 'ParameterMissing', message: error_message }] }, status: :unprocessable_entity
    end

  private

    def exports
      DataAPI::TADExport.all
      .select(:completed_at, :name, :id, :updated_at)
      .where('updated_at > ?', updated_since_params)
    end

    def serve_export(export)
      export.update!(audit_comment: "File downloaded via API using token ID #{@authenticating_token.id}")
      send_data export.file.download, filename: export.filename
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

    def updated_since_params
      updated_since_value = params.require(:updated_since)

      begin
        date = Time.zone.iso8601(updated_since_value)
        raise ParameterInvalid, 'Parameter is invalid (date is invalid): updated_since' unless date.year.positive?

        date
      rescue ArgumentError, KeyError
        raise ParameterInvalid, 'Parameter is invalid (should be ISO8601): updated_since'
      end
    end
  end
end
