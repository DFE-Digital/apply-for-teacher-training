class StateChangeNotifier
  APPLICATION_OUTCOME_EVENTS = %i[rejected declined withdrawn recruited].freeze

  attr_reader :application_choice, :event

  def initialize(event, application_choice)
    @event = event
    @application_choice = application_choice
  end

  def application_outcome_notification
    candidate_name = application_choice.application_form.first_name
    other_applications = application_choice.self_and_siblings.where.not(id: application_choice.id)
    providers = [application_choice.course.provider.name]

    if event == :rejected
      providers += other_applications.select(&:rejected?).map(&:provider).map(&:name)

      declined_message = declined_text_for(other_applications)
      withdrawn_message = withdrawn_text_for(other_applications)
      other_applications_outcome = [declined_message, withdrawn_message].compact.to_sentence
    elsif event == :withdrawn
      providers += other_applications.select(&:withdrawn?).map(&:provider).map(&:name)

      declined_message = declined_text_for(other_applications)
      rejected_message = rejected_text_for(other_applications)
      other_applications_outcome = [declined_message, rejected_message].compact.to_sentence
    elsif event == :declined
      providers += other_applications.select(&:declined?).map(&:provider).map(&:name)

      withdrawn_message = withdrawn_text_for(other_applications)
      rejected_message = rejected_text_for(other_applications)
      other_applications_outcome = [withdrawn_message, rejected_message].compact.to_sentence
    elsif event == :recruited
      declined_message = declined_text_for(other_applications)
      withdrawn_message = withdrawn_text_for(other_applications)
      rejected_message = rejected_text_for(other_applications)
      other_applications_outcome = [declined_message, withdrawn_message, rejected_message].compact.to_sentence
    end

    message = I18n.t("slack_notifications.#{event}.message", applicant: candidate_name, providers: providers.to_sentence)
    message << " #{candidate_name} previously #{other_applications_outcome}." if other_applications_outcome.present?

    url = StateChangeNotifier.helpers.support_interface_application_form_url(application_choice.application_form)

    StateChangeNotifier.send(message, url)
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
    return new(event, application_choice).application_outcome_notification if APPLICATION_OUTCOME_EVENTS.include?(event)

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

private

  def declined_text_for(applications)
    declined = applications.select(&:declined?).map(&:provider).map(&:name)
    declined.any? ? "declined offers from #{declined.to_sentence}" : nil
  end

  def withdrawn_text_for(applications)
    withdrawn = applications.select(&:withdrawn?).map(&:provider).map(&:name)
    withdrawn.any? ? "withdrew from #{withdrawn.to_sentence}" : nil
  end

  def rejected_text_for(applications)
    rejected = applications.select(&:rejected?).map(&:provider).map(&:name)
    rejected.any? ? "was rejected by #{rejected.to_sentence}" : nil
  end
end
