class RecalculateDates
  include Sidekiq::Worker

  def perform(*)
    Audited.audit_class.as_user('RecalculateDates worker') do
      ApplicationChoice
        .where(status: :awaiting_provider_decision)
        .includes(:application_form)
        .find_each do |application_choice|
          SetRejectByDefault.new(application_choice).call
        end

      application_forms_with_offers = ApplicationForm.where(
        id: ApplicationChoice.where(status: :offer).select(:application_form_id),
      )

      application_forms_with_offers.find_each do |application_form|
        SetDeclineByDefault.new(application_form: application_form).call
      end
    end

    ucas_1st_june_adjustment
  end

  def ucas_1st_june_adjustment
    # All code related to the UCAS adjustment can be removed 2020-06-01.
    #
    # For the second freeze period, UCAS have introduced a manual adjustment to
    # how RBDs and DBDs should be recalculated.
    #
    start_of_second_freeze = DateTime.parse('2020-04-20')
    end_of_second_freeze = DateTime.parse('2020-05-31')
    #
    # Any RBDs and DBDs that were *initially* recalculated to fall between the
    # 20th of April and the 31st of May must be manually adjusted to the
    # 1st of June.
    #
    adjustment_date = DateTime.parse('2020-06-01 23:59:59 +0100')
    #
    # For RBDs, the choices that require adjustment should all have RBDs that
    # fall in the ~6 week period after the end of the second freeze.
    #
    duration_of_freeze = end_of_second_freeze - start_of_second_freeze # ~6.weeks
    period_to_adjust_rbd = end_of_second_freeze..(end_of_second_freeze + duration_of_freeze)
    #
    # For DBDs, the choices that require adjustment should all have DBDs that
    # fall in the <=9 business day period after the end of the second freeze.
    #
    period_to_adjust_dbd = end_of_second_freeze..(9.business_days.after(end_of_second_freeze))

    Audited.audit_class.as_user('RecalculateDates worker UCAS 1st June adjustment') do
      ApplicationChoice
        .where(reject_by_default_at: period_to_adjust_rbd)
        .find_each do |application_choice|
          application_choice.update!(reject_by_default_at: adjustment_date)
        end

      ApplicationChoice
        .where(decline_by_default_at: period_to_adjust_dbd)
        .find_each do |application_choice|
          application_choice.update!(decline_by_default_at: adjustment_date)
        end
    end
  end
end
