module WorkExperienceAPIData
  include FieldTruncation

  WORK_EXPERIENCE_BREAK_EXPLANATION_FIELD = 'WorkExperiences.properties.work_history_break_explanation'.freeze

  def work_history_break_explanation
    @work_history_break_explanation ||= if application_form.work_history_breaks
                                          application_form.work_history_breaks
                                        elsif application_form.application_work_history_breaks.any?
                                          application_form.application_work_history_breaks.map do |work_break|
                                            format_work_break(work_break)
                                          end.join("\n\n")
                                        else
                                          ''
                                        end

    truncate_if_over_advertised_limit(WORK_EXPERIENCE_BREAK_EXPLANATION_FIELD, @work_history_break_explanation)
  end

  def work_experience_jobs
    application_form.application_work_experiences.map do |experience|
      experience_to_hash(experience)
    end
  end

  def work_experience_volunteering
    application_form.application_volunteering_experiences.map do |experience|
      experience_to_hash(experience)
    end
  end

  def format_work_break(work_break)
    start_date = work_break.start_date.to_fs(:month_and_year)
    end_date = work_break.end_date.to_fs(:month_and_year)

    "#{start_date} to #{end_date}: #{work_break.reason}"
  end

  def experience_to_hash(experience)
    {
      id: experience.id,
      start_date: experience.start_date.to_date,
      end_date: experience.end_date&.to_date,
      role: experience.role,
      organisation_name: experience.organisation,
      working_with_children: experience.working_with_children,
      commitment: experience.commitment,
      description: experience_description(experience),
    }
  end

  def experience_description(experience)
    return experience.details if experience.working_pattern.blank?

    "Working pattern: #{experience.working_pattern}\n\nDescription: #{experience.details}"
  end
end
