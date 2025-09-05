module SupportInterface
  class NotificationPreferencesComponent < ApplicationComponent
    include ViewHelper

    attr_reader :rows

    def initialize(rows:)
      @rows = rows
    end
  end
end
