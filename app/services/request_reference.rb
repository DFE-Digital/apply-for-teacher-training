class RequestReference
  attr_accessor :referee_params, :referee, :application_form

  BOT_EMAIL_ADDRESSES = ['refbot1@example.com', 'refbot2@example.com'].freeze

  def initialize(referee_params:, application_form:)
    self.referee_params = referee_params
    self.application_form = application_form
  end

  def call
    @referee = application_form.application_references.build(referee_params)
    auto_approve_in_sandbox
    @referee.save
  end

private

  def auto_approve_in_sandbox
    @referee.feedback = I18n.t('new_referee_request.auto_approve_feedback') if sandbox? && email_address_is_a_bot?
  end

  def sandbox?
    ENV.fetch('SANDBOX') { 'false' } == 'true'
  end

  def email_address_is_a_bot?
    BOT_EMAIL_ADDRESSES.include?(@referee.email_address)
  end
end
