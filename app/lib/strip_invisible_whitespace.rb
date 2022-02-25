class StripInvisibleWhitespace
  def self.from_hash(hash)
    hash.transform_values { |v| from_string(v) }
  end

  def self.from_string(value)
    return value unless value.is_a?(String)
    return value if value.frozen?

    value.gsub(/[#{StripAttributes::MULTIBYTE_WHITE}]+/, '')
  end
end
