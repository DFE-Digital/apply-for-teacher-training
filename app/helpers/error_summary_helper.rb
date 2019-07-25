module ErrorSummaryHelper
  def anchor_link(record, field)
    "##{record.model_name.param_key}_#{field}"
  end
end
