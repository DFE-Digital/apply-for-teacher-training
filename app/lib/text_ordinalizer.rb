class TextOrdinalizer
  def self.call(value)
    text_ordinalize(value)
  end

  class << self
  private

    ORDINALIZE_MAPPING = %w[zeroth first second third fourth fifth sixth seventh
                            eighth ninth tenth].freeze

    def text_ordinalize(value)
      ORDINALIZE_MAPPING[value] || value.ordinalize
    end
  end
end
