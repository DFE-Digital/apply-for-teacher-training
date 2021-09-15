class CourseAgeGroupMonthlyStatistics
  def call
    totals
  end

private

  def totals
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

    # this is the combined total of all the statuses per level
    counts.map do |level, status_count_hash|
      counts[level].merge!('total' => status_count_hash.values.inject(&:+))
    end

    counts
  end

  def group_query
    # Response has the following structure:
    # {
    #   ["Secondary", "withdrawn"]=>1,
    #   ["Primary", "rejected"]=>3,
    #   ["Primary", "unsubmitted"]=>1,
    #   ["Primary", "pending_conditions"]=>1,
    #   ["Secondary", "rejected"]=>3 ...
    # }

    ApplicationChoice
      .joins(:course)
      .where(current_recruitment_cycle_year: RecruitmentCycle.current_year)
      .group('courses.level', 'status')
      .count
  end
end
