require 'zip'

module ProviderInterface
  class DiversityReportExport
    attr_reader :provider, :recruitment_cycle_year

    def initialize(provider:, recruitment_cycle_year:)
      @provider = provider
      @recruitment_cycle_year = recruitment_cycle_year
    end

    def diversity_data
      DiversityDataByProvider.new(
        provider:,
        recruitment_cycle_year:,
      )
    end

    def call
      export_folder = "tmp/#{Time.zone.today}-xr-export"
      timestamp = Time.zone.now.strftime('%Y%m%d_%H%M%S')

      FileUtils.mkdir_p(export_folder)

      %w[sex disability ethnicity age].each do |type|
        export_data = send("#{type}_export")
        csv_filename = "#{type}_#{timestamp}.csv"
        File.write("#{export_folder}/#{csv_filename}", export_data)
      end

      zip_filename = "#{export_folder}.zip"
      Zip::OutputStream.open(zip_filename) do |zos|
        %w[sex disability ethnicity age].each do |type|
          csv_filename = "#{type}_#{timestamp}.csv"
          zos.put_next_entry(csv_filename)
          zos.write(File.read("#{export_folder}/#{csv_filename}"))
        end
      end

      FileUtils.remove_dir(export_folder)

      zip_filename
    end

  private

    def export_csv(type, folder)
      export_data = send("#{type}_export")
      timestamp = Time.zone.now.strftime('%Y%m%d_%H%M%S')
      File.write("#{folder}/#{type}_#{timestamp}.csv", export_data)
    end

    def prepare_export(type)
      data = diversity_data.public_send("#{type}_data")
      data.map do |rows|
        {
          "#{type}": rows[:header],
          applied: rows[:values].first,
          offered: rows[:values].second,
          recruited: rows[:values].third,
          percentage_recruited: rows[:values].fourth,
        }
      end
    end

    def sex_export
      export_data = prepare_export(:sex)
      SafeCSV.generate(export_data.map(&:values), export_data.first.keys)
    end

    def disability_export
      export_data = prepare_export(:disability)
      SafeCSV.generate(export_data.map(&:values), export_data.first.keys)
    end

    def ethnicity_export
      export_data = prepare_export(:ethnicity)
      SafeCSV.generate(export_data.map(&:values), export_data.first.keys)
    end

    def age_export
      export_data = prepare_export(:age)
      SafeCSV.generate(export_data.map(&:values), export_data.first.keys)
    end
  end
end
