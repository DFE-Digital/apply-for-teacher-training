module SupportInterface
  class DataExportsController < SupportInterfaceController
    PAGY_PER_PAGE = 30

    def show
      @data_export = DataExport.active_exports.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render_404
    end

    def directory
      @export_types = DataExport.active_export_types
    end

    def history
      @data_exports = DataExport
                        .active_exports
                        .includes(:initiator)
                        .order(created_at: :desc)
                        .select(DataExport.column_names - %w[data])

      @pagy, @data_exports = pagy(@data_exports, limit: PAGY_PER_PAGE)
    end

    def view_export_information
      export_type = params.fetch(:data_export_type)
      if DataExport.export_type_active?(export_type)
        @data_export_type = DataExport.active_export_types[params[:data_export_type].to_sym]
      else
        render_404
        nil
      end
    end

    def view_history
      export_type = params.fetch(:data_export_type)
      if DataExport.export_type_active?(export_type)
        @data_exports = DataExport
                          .active_exports
                          .includes(:initiator)
                          .send(params[:data_export_type])
                          .order(created_at: :desc)

        @pagy, @data_exports = pagy(@data_exports, limit: PAGY_PER_PAGE)

        @data_exports = @data_exports.select(DataExport.column_names - %w[data])
      else
        render_404
        nil
      end
    end

    def new
      @export_types = DataExport.active_export_types
    end

    def create
      export_type = DataExport.active_export_types.fetch(params.fetch(:export_type_id).to_sym)
      if export_type.present?
        data_export = DataExport.create!(name: export_type.fetch(:name), initiator: current_support_user, export_type: export_type.fetch(:export_type))
        DataExporter.perform_async(export_type.fetch(:class).to_s, data_export.id, export_options)
        redirect_to support_interface_data_export_path(data_export)
      else
        render render_404
        nil
      end
    end

    def download
      data_export = DataExport.active_exports.where.associated(:file_attachment).find(params[:id])
      data_export.update!(audit_comment: 'File downloaded')

      redirect_to rails_blob_path(data_export.file, disposition: 'attachment')
    end

    def data_set_documentation
      @export_type = DataExport.active_export_types.fetch(params.fetch(:export_type_id).to_sym)
    end

  private

    def export_options
      export_definition.fetch(:export_options, {})
    end

    def export_definition
      @export_definition ||= DataExport.active_export_types.fetch(params.fetch(:export_type_id).to_sym)
    end
  end
end
