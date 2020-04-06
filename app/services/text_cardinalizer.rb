class TextCardinalizer
  CARDINALIZE_MAPPING = %w[
    zero one two three four five six seven eight nine ten
  ].freeze

  def self.call(value)
    text_cardinalize(value)
  end

  class << self
  private

    def text_cardinalize(value)
      CARDINALIZE_MAPPING[value] || value.to_s
    end
  end
end
