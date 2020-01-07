module AriaDescribedbyHelper
  def generate_id(section:, entry_id:, attribute:)
    "#{section}-#{entry_id}-#{attribute}"
  end

  def generate_aria_describedby(section:, entry_id:, attributes:)
    element_ids = attributes.map do |attribute|
      generate_id(section: section, entry_id: entry_id, attribute: attribute)
    end

    element_ids.join(' ')
  end
end
