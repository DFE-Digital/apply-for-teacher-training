class SendChaseEmailToProvider
  def self.call(application_choice:)
    application_choice.provider.provider_users.each do |provider_user|
      ProviderMailer.chase_provider_decision(provider_user, application_choice).deliver_later
    end

    ChaserSent.create!(chased: application_choice, chaser_type: :provider_decision_request)
  end
end
