module SupportInterface
  class UCASMatchesStatisticsComponent < ViewComponent::Base
    include ViewHelper

    def initialize(ucas_matches)
      @ucas_matches = ucas_matches
    end

    def candidates_on_apply_count
      @candidates_on_apply_count ||= ApplicationChoice
        .where(status: ApplicationStateChange::STATES_VISIBLE_TO_PROVIDER)
        .includes([:application_form])
        .where(application_forms: { recruitment_cycle_year: recruitment_cycle_years }).references(:application_forms)
        .map(&:application_form).map(&:candidate_id).uniq.compact.size
    end

    def candidates_matched_with_ucas_count_and_percentage
      count = @ucas_matches.size

      "#{count} (#{formatted_percentage(count, candidates_on_apply_count)})"
    end

    def applied_for_the_same_course_on_both_services
      "#{dual_applications_count} (#{formatted_percentage(dual_applications_count, candidates_on_apply_count)} of candidates on Apply)"
    end

    def accepted_offers_on_both_services
      "#{multiple_acceptances_count} (#{formatted_percentage(multiple_acceptances_count, candidates_on_apply_count)} of candidates on Apply)"
    end

    def candidates_with_dual_applications_or_dual_acceptance
      dual_applications_count + multiple_acceptances_count
    end

    def unresolved_count
      [action_taken_count['initial_emails_sent'],
       action_taken_count['reminder_emails_sent'],
       action_taken_count['ucas_withdrawal_requested']].compact.sum
    end

    def action_taken_count
      @ucas_matches.pluck(:action_taken).tally
    end

  private

    def dual_applications_count
      both_scheme_array = @ucas_matches.map do |ucas_match|
        ucas_match.ucas_matched_applications.map(&:both_scheme?).any?
      end

      both_scheme_array.count(true)
    end

    def multiple_acceptances_count
      # Since the statuses get updated daily, we also include matches that were
      # in this situation but are now resolved.
      # Matches which were marked as manually resolved are not counted twice.
      [@ucas_matches.select(&:application_accepted_on_ucas_and_accepted_on_apply?),
       resolved_multiple_acceptances].uniq.count
    end

    def resolved_multiple_acceptances
      @ucas_matches.select(&:resolved?).reject do |ucas_match|
        ucas_match.ucas_matched_applications.map(&:both_scheme?).any?
      end
    end

    def recruitment_cycle_years
      @ucas_matches.distinct.pluck(:recruitment_cycle_year)
    end

    def formatted_percentage(count, total)
      percentage = count.percent_of(total)
      precision = (percentage % 1).zero? ? 0 : 2
      number_to_percentage(percentage, precision: precision)
    end
  end
end

class Numeric
  def percent_of(number)
    to_f / number * 100.0
  end
end
