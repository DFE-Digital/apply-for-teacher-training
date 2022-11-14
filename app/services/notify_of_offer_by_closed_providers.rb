class NotifyOfOfferByClosedProviders
  CLOSED_PROVIDERS = %w[
    24R
    B28
    26T
    B60
    B84
    C23
    25P
    C97
    D51
    2B6
    M70
    E73
    F82
    252
    G10
    G12
    2B4
    26U
    2AW
    1LP
    2B5
    25O
    1WK
    2AY
    L26
    L35
    L75
    N55
    N46
    25K
    N83
    24U
    255
    P38
    2ET
    R55
    L06
    G15
    S13
    E37
    25D
    T11
    2EZ
    T26
    B17
    C36
    H17
    L19
    24P
    2AZ
    T29
    1WW
    T89
    B35
    C99
    D86
    E14
    G70
    H72
    P60
    S90
    B80
    W34
    2B2
  ].freeze

  attr_reader :provider, :application_choice, :accredited_provider

  def initialize(application_choice:)
    @provider = application_choice.course.provider
    @accredited_provider = application_choice.course.accredited_provider
    @application_choice = application_choice
  end

  def call
    send_slack_notification if provider_closed?
  end

private

  def provider_closed?
    CLOSED_PROVIDERS.include?(provider.code) || CLOSED_PROVIDERS.include?(accredited_provider.code)
  end

  def send_slack_notification
    message = ":bangbang: #{provider.name} has made an offer to a candidate – this provider is currently closed."
    url = Rails.application.routes.url_helpers.support_interface_application_form_url(application_choice.application_form)

    SlackNotificationWorker.perform_async(message, url, '#bat_provider_changes')
  end
end
