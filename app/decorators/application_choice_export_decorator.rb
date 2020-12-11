class ApplicationChoiceExportDecorator < SimpleDelegator
  def gcse_qualifications_summary
    gcses = %i[maths_gcse english_gcse science_gcse]
    summary_string = gcses
      .map { |gcse| application_form.send(gcse) }
      .map { |gcse| summary_for_gcse(gcse) }
      .compact
      .join(',')

    summary_string.presence
  end

  def missing_gcses_explanation(separator_string: ',')
    application_form
      .application_qualifications
      .select { |q| q.level == 'gcse' }
      .select(&:missing_qualification?)
      .map { |gcse| "#{gcse.subject.capitalize} GCSE or equivalent: #{gcse.missing_explanation}" }
      .join(separator_string)
      .presence
  end

  def degrees_completed_flag
    application_form.degrees_completed ? 1 : 0
  end

private

  def missing_gcse_explanation(gcse)
    "#{gcse.subject.capitalize} GCSE or equivalent: #{gcse.missing_explanation}"
  end

  def summary_for_gcse(gcse)
    "#{gcse.qualification_type.humanize} #{gcse.subject.capitalize}, #{gcse.grade}, #{gcse.start_year}-#{gcse.award_year}" if gcse.present?
  end
end
