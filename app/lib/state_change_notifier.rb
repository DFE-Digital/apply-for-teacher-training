class StateChangeNotifier
  def self.sign_up(candidate)
    candidate_number = Candidate.where(hide_in_reporting: false).count

    return unless (candidate_number % 25).zero?

    candidate_number_is_significant = (candidate_number % 100).zero?
    text = if candidate_number_is_significant
             ":ultrafastparrot: The #{candidate_number.ordinalize} candidate just signed up"
           else
             ":sparkles: The #{candidate_number.ordinalize} candidate just signed up"
           end

    url = helpers.support_interface_candidate_url(candidate)

    send(text, url)
  end

  def self.submit_application(application_form)
    message = ":rocket: #{application_form.first_name}’s application has been sent to #{application_form.application_choices.map(&:provider).map(&:name).to_sentence}"
    url = helpers.support_interface_application_form_url(application_form)

    send(message, url)
  end

  def self.accept_offer(accepted:, withdrawn: [], declined: [])
    accepted_msg = "#{accepted.application_form.first_name} has accepted #{accepted.offered_option.course.provider.name}’s offer for #{accepted.offered_option.course.name_and_code}"

    if withdrawn.any?
      withdrawn_msg = "withdrawn their #{'application'.pluralize(withdrawn.count)} for "
      withdrawals = withdrawn.map do |ac|
        "#{ac.offered_option.course.name_and_code} at #{ac.offered_option.course.provider.name}"
      end

      withdrawn_msg += withdrawals.to_sentence
    end

    if declined.any?
      declined_msg = 'declined '
      declines = declined.map do |ac|
        "#{ac.offered_option.course.provider.name}’s offer for #{ac.offered_option.course.name_and_code}"
      end

      declined_msg += declines.to_sentence
    end

    message = ":handshake: #{[accepted_msg, withdrawn_msg, declined_msg].compact.to_sentence}."
    url = helpers.support_interface_application_form_url(accepted.application_form)

    send(message, url)
  end

  def self.call(event, application_choice: nil)
    provider_name = application_choice.course.provider.name
    course_name = application_choice.course.name_and_code
    candidate_name = application_choice.application_form.first_name
    application_form = application_choice.application_form

    case event
    when :make_an_offer
      text = ":love_letter: #{provider_name} has just made an offer to #{candidate_name}’s application"
    when :change_an_offer
      text = ":love_letter: #{provider_name} has just changed an offer for #{candidate_name}’s application"
    when :reject_application
      text = ":broken_heart: #{provider_name} has just rejected #{candidate_name}’s application"
    when :reject_application_by_default
      text = ":broken_heart: #{candidate_name}’s application to #{provider_name} has just been rejected by default"
    when :offer_declined
      text = ":no_good: #{candidate_name} has declined #{provider_name}’s offer"
    when :withdraw
      text = ":runner: #{candidate_name} has withdrawn their application for #{course_name} at #{provider_name}"
    when :withdraw_offer
      text = ":no_good: #{provider_name} has just withdrawn #{candidate_name}’s offer"
    when :defer_offer
      text = ":double_vertical_bar: #{provider_name} has just deferred #{candidate_name}’s offer"
    when :reinstate_offer_conditions_met
      text = ":arrow_forward: #{provider_name} has just reinstated their offer to #{candidate_name} (conditions met)"
    when :reinstate_offer_pending_conditions
      text = ":arrow_forward: #{provider_name} has just reinstated their offer to #{candidate_name} (pending conditions)"
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
