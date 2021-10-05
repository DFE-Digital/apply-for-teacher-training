module BigqueryDataConversion
private

  def entity_data(attributes, table_name)
    exportable_attrs = Rails.configuration.analytics[table_name.to_sym].presence || []
    pii_attrs = Rails.configuration.analytics_pii[table_name.to_sym].presence || []
    exportable_pii_attrs = exportable_attrs & pii_attrs

    allowed_attributes = attributes.slice(*exportable_attrs&.map(&:to_s))
    obfuscated_attributes = attributes.slice(*exportable_pii_attrs&.map(&:to_s))

    allowed_attributes.deep_merge(obfuscated_attributes.transform_values { |value| anonymise(value) })
  end

  def anonymise(value)
    Digest::SHA2.hexdigest(value.to_s)
  end
end
