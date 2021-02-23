class FlatReasonsForRejectionExtract
  include ActiveModel::Model
  include ReasonsForRejection

  def initialize(structured_rejection_reasons)
    # @structured_rejection_reasons = application_form.application_choices.structured_rejection_reasons
    @structured_rejection_reasons = structured_rejection_reasons
  end

  def separate_high_level_rejection_reasons(structured_rejection_reasons)
    select_high_level_rejection_reasons(structured_rejection_reasons)
    .keys
    .map { |reason| format_reason(reason) }
  end

  def candidate_behaviour
    return nil if @structured_rejection_reasons.blank?
    @structured_rejection_reasons.select { |reason, value| value == 'candidate_behaviour_y_n' }

    select_high_level_rejection_reasons(structured_rejection_reasons)
    .keys
    .map { |reason| format_reason(reason) }
  end

  def candidate_behaviour_sub_reasons


  end

  def quality_of_application


  end

  def quality_of_application_sub_reasons


  end

  def candidate_behaviour


  end

  def candidate_behaviour_sub_reasons


  end



  # These three methods are copied from the application_choices_export.rb .... currently doesn't provide enough granularity
  def format_structured_rejection_reasons
    return nil if @structured_rejection_reasons.blank?

    select_high_level_rejection_reasons(@structured_rejection_reasons)
    .keys
    .map { |reason| format_reason(reason) }
    .join("\n")
  end

  def select_high_level_rejection_reasons(structured_rejection_reasons)
    structured_rejection_reasons.select { |reason, value| value == 'Yes' && reason.include?('_y_n') }
  end

  def format_reason(reason)
    reason
    .delete_suffix('_y_n')
    .humanize
  end
end
