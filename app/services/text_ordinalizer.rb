class TextOrdinalizer
  def self.call(value)
    text_ordinalize(value)
  end

  class << self
  private

    def text_ordinalize(value)
      ordinalize_mapping[value] || value.ordinalize
    end

    def ordinalize_mapping
      %w[zeroth first second third fourth fifth sixth seventh
         eighth ninth tenth]
    end
  end
end
