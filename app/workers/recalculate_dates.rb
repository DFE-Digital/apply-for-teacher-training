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
    adjustment_date = Time.zone.local(2020, 6, 1).end_of_day
    #
    #  All applications submitted to a provider before the 7th of March should
    # have an RBD of the 1st of June.
    #
    sent_to_provider_at_cutoff = DateTime.parse('2020-03-07')
    application_choices_that_need_new_rbd = ApplicationChoice
      .where(status: :awaiting_provider_decision)
      .where('sent_to_provider_at <= ?', sent_to_provider_at_cutoff)
      .where.not(reject_by_default_at: adjustment_date)
    #
    # All applications that have received an offer before the 20th of April
    # should have a DBD of the 1st of June.
    #
    offered_at_cutoff = DateTime.parse('2020-04-20')
    application_choices_that_need_new_dbd = ApplicationChoice
      .where(status: :offer)
      .where('offered_at <= ?', offered_at_cutoff)
      .where.not(decline_by_default_at: adjustment_date)

    Audited.audit_class.as_user('RecalculateDates worker UCAS 1st June adjustment') do
      application_choices_that_need_new_rbd.find_each do |application_choice|
        application_choice.update!(reject_by_default_at: adjustment_date)
      end

      application_choices_that_need_new_dbd.find_each do |application_choice|
        application_choice.update!(decline_by_default_at: adjustment_date)
      end
    end
  end
end
