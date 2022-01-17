require 'csv'

class SafeCSV
  WHITELISTED_VALUES = [
    '-', # this is used for course codes and it is not, on its own, a legitimate formula
  ].freeze

  def self.generate(values, header_row = nil)
    CSV.generate do |rows|
      rows << header_row if header_row.present?
      values&.each do |value|
        rows << SafeCSV.sanitise(value)
      end
    end
  end

  def self.generate_line(values)
    CSV.generate_line(values&.map { |value| SafeCSV.sanitise(value) })
  end

  def self.sanitise(value)
    return value.map { |v| sanitise_formulae(v) } if value.is_a?(Array)

    sanitise_formulae(value)
  end

  def self.sanitise_formulae(value)
    value.to_s.starts_with?(/[\-+=@]/) && WHITELISTED_VALUES.exclude?(value) ? value.gsub(/^([\-+=@].*)/, '.\1') : value
  end
end
