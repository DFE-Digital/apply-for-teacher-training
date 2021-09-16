class CourseAgeGroupMonthlyStatistics
  def call
    table_data
  end

private

  def table_data
    formatted_group_query.map do |age_group, statuses|
      {
        'Age group' => age_group,
        'Recruited' => recruited_count(statuses),
        'Conditions pending' => pending_count(statuses),
        'Received an offer' => offer_count(statuses),
        'Awaiting provider decisions' => awaiting_decision_count(statuses),
        'Unsuccessful' => unsuccessful_count(statuses),
        'Total' => statuses_count(statuses),
      }
    end
  end

  def formatted_group_query
    counts = {
      'Primary' => {},
      'Secondary' => {},
      'Further education' => {},
      # Still need to calculate 'Total' => {}
    }

    group_query.map do |item|
      level, status = item[0]
      count = item[1]
      counts[level].merge!({ status => count })
    end

    counts
  end

  def group_query
    ApplicationChoice
      .joins(:course)
      .where(current_recruitment_cycle_year: RecruitmentCycle.current_year)
      .group('courses.level', 'status')
      .count
  end

  # there must be a cleaner way to calculate the counts

  def recruited_count(statuses)
    statuses['recruited'] || 0
  end

  def pending_count(statuses)
    statuses['pending_conditions'] || 0
  end

  def offer_count(statuses)
    statuses['offer'] || 0
  end

  def awaiting_decision_count(statuses)
    (statuses['awaiting_provider_decision'] || 0) + (statuses['interviewing'] || 0)
  end

  def unsuccessful_count(statuses)
    (statuses['declined'] || 0) + (statuses['rejected'] || 0)
  end

  def statuses_count(statuses)
    recruited_count(statuses) +
      pending_count(statuses) +
      offer_count(statuses) +
      awaiting_decision_count(statuses) +
      unsuccessful_count(statuses)
  end
end
