module SupportInterface
  class NotificationPreferencesComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :rows

    def initialize(rows:)
      @rows = rows
    end
  end
end
