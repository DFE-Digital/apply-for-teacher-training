module WorkExperienceAPIData
  include FieldTruncation

  WORK_EXPERIENCE_BREAK_EXPLANATION_FIELD = 'WorkExperiences.properties.work_history_break_explanation'.freeze

  def work_history_break_explanation
    @work_history_break_explanation ||= if application_form.work_history_breaks
                                          application_form.work_history_breaks
                                        elsif application_choice.application_work_history_breaks.any?
                                          application_choice.application_work_history_breaks.map do |work_break|
                                            format_work_break(work_break)
                                          end.join("\n\n")
                                        else
                                          ''
                                        end

    truncate_if_over_advertised_limit(WORK_EXPERIENCE_BREAK_EXPLANATION_FIELD, @work_history_break_explanation)
  end

  def work_experience_jobs
    application_choice.application_work_experiences.map do |experience|
      experience_to_hash(experience)
    end
  end

  def work_experience_volunteering
    application_choice.application_volunteering_experiences.map do |experience|
      experience_to_hash(experience)
    end
  end

  def format_work_break(work_break)
    start_date = work_break.start_date.to_fs(:month_and_year)
    end_date = work_break.end_date.to_fs(:month_and_year)

    "#{start_date} to #{end_date}: #{work_break.reason}"
  end

  def experience_to_hash(experience)
    basic_properties = {
      id: experience.id,
      role: experience.role,
      organisation_name: experience.organisation,
      working_with_children: experience.working_with_children,
      commitment: experience.commitment,
      description: experience_description(experience),
    }

    basic_properties
      .merge(experience_dates(experience))
      .merge(experience_skills(experience))
  end

  def experience_dates(experience)
    basic_dates = {
      start_date: experience.start_date.to_date,
      end_date: experience.end_date&.to_date,
    }

    return basic_dates unless version_1_3_or_above?

    basic_dates.merge(
      start_month: {
        month: experience.start_date.strftime('%m'),
        year: experience.start_date.strftime('%Y'),
        estimated: experience.start_date_unknown,
      },
    ).tap do |hash|
      hash[:end_month] = if (date = experience.end_date)
                           {
                             month: date.strftime('%m'),
                             year: date.strftime('%Y'),
                             estimated: experience.end_date_unknown,
                           }
                         end
    end
  end

  def experience_skills(experience)
    return {} unless version_1_3_or_above?

    { skills_relevant_to_teaching: experience.relevant_skills }
  end

  def experience_description(experience)
    return experience.details if experience.working_pattern.blank?

    "Working pattern: #{experience.working_pattern}\n\nDescription: #{experience.details}"
  end

  def version_1_3_or_above?
    Gem::Version.new(active_version) >= Gem::Version.new('1.3')
  end
end
