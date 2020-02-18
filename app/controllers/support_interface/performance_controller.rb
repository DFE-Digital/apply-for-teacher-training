require 'csv'

module SupportInterface
  class PerformanceController < SupportInterfaceController
    def index; end

    def application_timings
      applications = SupportInterface::ApplicationsExport.new.applications

      csv = CSV.generate do |rows|
        rows << applications.first.keys

        applications.each do |a|
          rows << a.values
        end
      end

      render plain: csv
    end
  end
end
