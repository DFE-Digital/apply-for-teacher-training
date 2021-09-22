class StateChangeNotifier
  attr_reader :application_choice, :event

  def initialize(event, application_choice)
    @event = event
    @application_choice = application_choice
  end

  def self.sign_up(candidate)
    candidate_number = Candidate.where(hide_in_reporting: false).count

    return unless (candidate_number % 100).zero?

    candidate_number_is_significant = (candidate_number % 500).zero?
    ordinal_number = "#{ActiveSupport::NumberHelper.number_to_delimited(candidate_number)}#{candidate_number.ordinal}"
    milestone = candidate_number_is_significant ? 'major' : 'minor'
    text = I18n.t("slack_notifications.sign_up.#{milestone}_milestone", candidate_number: ordinal_number)
    url = helpers.support_interface_candidate_url(candidate)

    send(text, url)
  end

  def self.call(event, application_choice: nil)
    provider_name = application_choice.course.provider.name
    candidate_name = application_choice.application_form.first_name
    application_form = application_choice.application_form

    case event
    when :change_an_offer
      text = ":love_letter: #{provider_name} has changed an offer for #{candidate_name}’s application"
    when :defer_offer
      text = ":double_vertical_bar: #{provider_name} has deferred #{candidate_name}’s offer"
    else
      raise 'StateChangeNotifier: unsupported state transition event'
    end

    url = helpers.support_interface_application_form_url(application_form)

    send(text, url)
  end

  def self.send(text, url)
    if RequestStore.store[:disable_state_change_notifications]
      Rails.logger.info "Sending Slack messages disabled (message: `#{text}`)"
      return
    end

    SlackNotificationWorker.perform_async(text, url)
  end

  def self.helpers
    Rails.application.routes.url_helpers
  end

  def self.disable_notifications
    # support nesting these blocks
    prior_state = RequestStore.store[:disable_state_change_notifications].presence || false

    RequestStore.store[:disable_state_change_notifications] = true
    yield
    RequestStore.store[:disable_state_change_notifications] = prior_state
  end
end
