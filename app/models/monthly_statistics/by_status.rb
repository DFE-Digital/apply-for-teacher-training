module MonthlyStatistics
  class ByStatus
    def initialize(by_candidate: false)
      @by_candidate = by_candidate
    end

    def table_data
      {
        rows: rows,
        column_totals: column_totals_for(rows),
      }
    end

  private

    def rows
      @rows ||= formatted_counts.map do |status, phases|
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

    def formatted_counts
      counts = {
        'Recruited' => { 'apply_1' => 0, 'apply_2' => 0 },
        'Conditions pending' => { 'apply_1' => 0, 'apply_2' => 0 },
        'Received an offer but not responded' => { 'apply_1' => 0, 'apply_2' => 0 },
        'Awaiting provider decisions' => { 'apply_1' => 0, 'apply_2' => 0 },
        'Declined an offer' => { 'apply_1' => 0, 'apply_2' => 0 },
        'Withdrew an application' => { 'apply_1' => 0, 'apply_2' => 0 },
        'Application rejected' => { 'apply_1' => 0, 'apply_2' => 0 },
      }

      combined_application_choice_states_tally = {
        'apply_1' => combined_application_choice_states_tally('apply_1'),
        'apply_2' => combined_application_choice_states_tally('apply_2'),
      }

      combined_application_choice_states_tally.map do |phase, tally|
        tally.map do |status, count|
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
      end

      counts
    end

    def combined_application_choice_states_tally(phase)
      tally_application_choices(phase).merge!(tally_deferred_application_choices(phase)) do |_key, count, deferred_count|
        [count, deferred_count].inject(:+)
      end
    end

    def tally_application_choices(phase)
      scope = ApplicationForm
        .includes(:application_choices)
        .current_cycle
        .where(phase: phase)

      scope = scope.without_subsequent_applications if @by_candidate

      scope.map { |application_form| application_form.top_ranked_application_choice_status(:status) }
        .tally
    end

    def tally_deferred_application_choices(phase)
      scope = ApplicationForm
        .includes(:application_choices)
        .where(recruitment_cycle_year: RecruitmentCycle.previous_year)
        .where(phase: phase)

      scope = scope.without_subsequent_applications if @by_candidate

      scope.map { |application_form| application_form.top_ranked_application_choice_status(:status_before_deferral) }
        .tally
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
