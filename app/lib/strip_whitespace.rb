class StripWhitespace
  def self.from_hash(hash)
    hash.transform_values { |v| from_string(v) }
  end

  def self.from_string(string)
    StripAttributes.strip_string(string, allow_empty: true)
  end
end
