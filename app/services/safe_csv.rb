class CsvHelper
  def self.sanitise(value)
    return value.map { |v| sanitise_formulae(v) } if value.is_a?(Array)

    sanitise_formulae(value)
  end

  def self.sanitise_formulae(value)
    value.to_s.starts_with?(/[\-+=@]/) ? value.gsub(/^([\-+=@].*)/, '.\1') : value
  end
end
