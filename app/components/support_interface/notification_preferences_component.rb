module SupportInterface
  class NotificationPreferencesComponent < BaseComponent
    include ViewHelper

    attr_reader :rows

    def initialize(rows:)
      @rows = rows
    end
  end
end
