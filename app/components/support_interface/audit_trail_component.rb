module SupportInterface
  class AuditTrailComponent < ViewComponent::Base
    include ViewHelper

    validates :audited_thing, presence: true

    def initialize(audited_thing:)
      @audited_thing = audited_thing
    end

    def audits
      audits = if audited_thing.is_a? Provider
                 audits_for_provider
               else
                 standard_audits
               end

      audits.includes(:user).order('id desc')
    end

    attr_reader :audited_thing

  private

    def audits_for_provider
      standard_audits.or(Audited::Audit.where(
                           auditable_type: 'ProviderRelationshipPermissions',
                           auditable_id: ProviderRelationshipPermissions.where(ratifying_provider_id: audited_thing.id),
                         ))
    end

    def standard_audits
      audited_thing.own_and_associated_audits.unscope(:order)
    end
  end
end
