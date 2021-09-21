module MonthlyStatistics
  class ApplicationsByStatus
    def table_data
      {
        rows: rows,
        column_totals: column_totals_for(rows),
      }
    end

  private

    def rows
      @rows ||= formatted_group_query.map do |status, phases|
        {
          'Status' => status,
          'First application' => apply_one_count(phases),
          'Apply again' => apply_again_count(phases),
          'Total' => phase_count(phases),
        }
      end
    end

    def column_totals_for(rows)
      _age_group, *statuses = rows.first.keys

      statuses.map do |column_name|
        column_total = rows.inject(0) { |total, hash| total + hash[column_name] }
        column_total
      end
    end

    def formatted_group_query
      counts = {
        'Recruited' => { 'apply_1' => 0, 'apply_2' => 0 },
        'Conditions pending' => { 'apply_1' => 0, 'apply_2' => 0 },
        'Received an offer but not responded' => { 'apply_1' => 0, 'apply_2' => 0 },
        'Awaiting provider decisions' => { 'apply_1' => 0, 'apply_2' => 0 },
        'Declined an offer' => { 'apply_1' => 0, 'apply_2' => 0 },
        'Withdrew an application' => { 'apply_1' => 0, 'apply_2' => 0 },
        'Application rejected' => { 'apply_1' => 0, 'apply_2' => 0 },
      }

      group_query.map do |(status, phase), count|
        case status
        when 'awaiting_provider_decision', 'interviewing'
          counts['Awaiting provider decisions'][phase] += count
        when 'conditions_not_met', 'offer_deferred'
          counts['Conditions pending'][phase] += count
        when 'offer'
          counts['Received an offer but not responded'][phase] += count
        when 'recruited'
          counts['Recruited'][phase] += count
        when 'rejected'
          counts['Application rejected'][phase] += count
        when 'withdrawn'
          counts['Withdrew an application'][phase] += count
        when 'declined'
          counts['Declined an offer'][phase] += count
        end
      end

      counts
    end

    def group_query
      ApplicationForm
        .where(recruitment_cycle_year: RecruitmentCycle.current_year)
        .joins(:application_choices)
        .group('application_choices.status', 'phase')
        .count
    end

    def apply_one_count(phases)
      phases['apply_1'] || 0
    end

    def apply_again_count(phases)
      phases['apply_2'] || 0
    end

    def phase_count(phases)
      apply_one_count(phases) + apply_again_count(phases)
    end
  end
end
