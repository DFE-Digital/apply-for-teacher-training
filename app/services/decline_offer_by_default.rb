class DeclineOfferByDefault
  attr_accessor :application_choice

  def initialize(application_choice:)
    self.application_choice = application_choice
  end

  def call
    ActiveRecord::Base.transaction do
      application_choice.update(declined_by_default: true, declined_at: Time.zone.now)
      ApplicationStateChange.new(application_choice).decline!
    end
  end
end
