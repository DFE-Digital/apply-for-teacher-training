module ErrorSummaryHelper
  def field_anchor_link(record, field)
    "##{record.model_name.param_key}_#{field}"
  end
end
