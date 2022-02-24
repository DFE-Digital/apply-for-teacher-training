class StripInvisibleWhitespace
  def self.from_hash(hash)
    hash.transform_values { |v| from_string(v) }
  end

  def self.from_string(string)
    string.gsub(/[#{StripAttributes::MULTIBYTE_WHITE}]+/, '')
  end
end
