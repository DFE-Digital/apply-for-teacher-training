module GcseStatementComparabilityPathHelper
  def x_gcse_new_statement_comparability_path(subject)
    send("candidate_interface_new_gcse_#{subject}_statement_comparability_path", subject:)
  end

  def x_gcse_edit_statement_comparability_path(subject)
    send("candidate_interface_edit_gcse_#{subject}_statement_comparability_path", subject:)
  end

  def new_international_flow_statement_comparability_path(subject)
    send("candidate_interface_new_international_flow_new_gcse_#{subject}_statement_comparability_path", subject:)
  end

  def edit_international_flow_statement_comparability_path(subject)
    send("candidate_interface_new_international_flow_edit_gcse_#{subject}_statement_comparability_path", subject:)
  end
end
