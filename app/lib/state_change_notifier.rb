class StateChangeNotifier
  def self.sign_up(candidate)
    helpers = Rails.application.routes.url_helpers
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

  def self.call(event, application_choice: nil, application_form: nil)
    helpers = Rails.application.routes.url_helpers

    if application_choice
      provider_name = application_choice.course.provider.name
      course_name = application_choice.course.name_and_code
      applicant = application_choice.application_form.first_name
      application_form_id = application_choice.application_form.id
    end

    case event
    when :make_an_offer
      text = ":love_letter: #{provider_name} has just made an offer to #{applicant}’s application"
      url = helpers.support_interface_application_form_url(application_form_id)
    when :change_an_offer
      text = ":love_letter: #{provider_name} has just changed an offer for #{applicant}’s application"
      url = helpers.support_interface_application_form_url(application_form_id)
    when :reject_application
      text = ":broken_heart: #{provider_name} has just rejected #{applicant}’s application"
      url = helpers.support_interface_application_form_url(application_form_id)
    when :reject_application_by_default
      text = ":broken_heart: #{applicant}’s application has just been rejected by default"
      url = helpers.support_interface_application_form_url(application_form_id)
    when :offer_accepted
      text = ":handshake: #{applicant} has accepted #{provider_name}’s offer"
      url = helpers.support_interface_application_form_url(application_form_id)
    when :offer_declined
      text = ":no_good: #{applicant} has declined #{provider_name}’s offer"
      url = helpers.support_interface_application_form_url(application_form_id)
    when :withdraw
      text = ":runner: #{applicant} has withdrawn their application for #{course_name} at #{provider_name}"
      url = helpers.support_interface_application_form_url(application_form_id)
    when :withdraw_offer
      text = ":no_good: #{provider_name} has just withdrawn #{applicant}’s offer"
      url = helpers.support_interface_application_form_url(application_form_id)
    when :defer_offer
      text = ":double_vertical_bar: #{provider_name} has just deferred #{applicant}’s offer"
      url = helpers.support_interface_application_form_url(application_form_id)
    when :reinstate_offer_conditions_met
      text = ":arrow_forward: #{provider_name} has just reinstated their offer to #{applicant} (conditions met)"
      url = helpers.support_interface_application_form_url(application_form_id)
    when :reinstate_offer_pending_conditions
      text = ":arrow_forward: #{provider_name} has just reinstated their offer to #{applicant} (pending conditions)"
      url = helpers.support_interface_application_form_url(application_form_id)
    else
      raise 'StateChangeNotifier: unsupported state transition event'
    end

    send(text, url)
  end

  def self.send(text, url)
    if RequestStore.store[:disable_slack_messages]
      Rails.logger.info "Sending Slack messages disabled (message: `#{text}`)"
      return
    end

    SlackNotificationWorker.perform_async(text, url)
  end
end
