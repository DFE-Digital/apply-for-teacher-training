module CSVNameHelper
  def csv_filename(export_name:, cycle_years:, providers:)
    "#{export_name}_#{year_range(cycle_years)}_#{provider_string(providers)}_#{Time.zone.now.strftime('%Y-%m-%d_%k-%M-%S')}.csv"
  end

private

  def year_range(cycle_years)
    sorted_cycle_years = cycle_years.sort - [0]
    integer_cycle_years = sorted_cycle_years.map(&:to_i)
    "#{integer_cycle_years.first - 1}-to-#{sorted_cycle_years.last}"
  end

  def provider_string(providers)
    providers.one? ? sanitized_provider_name(providers.first.name) : 'multiple-providers'
  end

  def sanitized_provider_name(name)
    name = name.gsub(/\s/, '-') # replace spaces with dashes
    name = name.gsub(/[^[:alnum:]-]/, '') # strip punctuation, except dashes
    name.downcase
  end
end
