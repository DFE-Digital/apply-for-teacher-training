module FormErrorSummaryHelper
  def field_anchor_link(model_name:, field:)
    "##{model_name.param_key}_#{field}"
  end
end
