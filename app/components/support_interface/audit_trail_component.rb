module SupportInterface
  class AuditTrailComponent < ViewComponent::Base
    include ViewHelper

    validates :audited_thing, presence: true

    def initialize(audited_thing:)
      @audited_thing = audited_thing
    end

    def audits
      audited_thing.own_and_associated_audits.includes(:user).order('id desc')
    end

    attr_reader :audited_thing
  end
end
