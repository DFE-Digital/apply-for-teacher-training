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
  end
end
