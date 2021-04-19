module SupportInterface
  class DataExportHistoryComponent < SummaryListComponent
    include ViewHelper

    attr_reader :data_exports, :show_name
    alias_method :show_name?, :show_name

    def initialize(data_exports:, show_name:)
      @data_exports = data_exports
      @show_name = show_name
    end
  end
end
