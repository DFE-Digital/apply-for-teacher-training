module SupportInterface
  class DataExportsController < SupportInterfaceController
    PAGY_PER_PAGE = 30

    def show
      @data_export = DataExport.find(params[:id])
    end

    def directory
      @export_types = DataExport::EXPORT_TYPES
    end

    def history
      @data_exports = DataExport
                       .includes(:initiator)
                       .order(created_at: :desc)
                       .select(DataExport.column_names - %w[data])

      @pagy, @data_exports = pagy(@data_exports, limit: PAGY_PER_PAGE)
    end

    def view_export_information
      @data_export_type = DataExport::EXPORT_TYPES[params[:data_export_type].to_sym]
    end

    def view_history
      @data_exports = DataExport
                       .includes(:initiator)
                       .send(params[:data_export_type])
                       .order(created_at: :desc)

      @pagy, @data_exports = pagy(@data_exports, limit: PAGY_PER_PAGE)

      @data_exports = @data_exports.select(DataExport.column_names - %w[data])
    end

    def new
      @export_types = DataExport.active_export_types
    end

    def create
      export_type = DataExport::EXPORT_TYPES.fetch(params.fetch(:export_type_id).to_sym)
      if export_type.fetch(:deprecated)
        flash[:warning] = 'This export type has been deprecated and cannot be generated'
        redirect_to support_interface_data_directory_path
      else
        data_export = DataExport.create!(name: export_type.fetch(:name), initiator: current_support_user, export_type: export_type.fetch(:export_type))
        DataExporter.perform_async(export_type.fetch(:class).to_s, data_export.id, export_options)
        redirect_to support_interface_data_export_path(data_export)
      end
    end

    def download
      data_export = DataExport.where.associated(:file_attachment).find(params[:id])
      if data_export.export_type_deprecated?
        flash[:warning] = 'This export type has been deprecated and is no longer available to download'
        redirect_to support_interface_data_directory_path
      else
        data_export.update!(audit_comment: 'File downloaded')

        redirect_to rails_blob_path(data_export.file, disposition: 'attachment')
      end
    end

    def data_set_documentation
      @export_type = DataExport::EXPORT_TYPES.fetch(params.fetch(:export_type_id).to_sym)
    end

  private

    def export_options
      export_definition.fetch(:export_options, {})
    end

    def export_definition
      @export_definition ||= DataExport::EXPORT_TYPES.fetch(params.fetch(:export_type_id).to_sym)
    end
  end
end
