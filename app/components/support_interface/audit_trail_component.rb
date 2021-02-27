module SupportInterface
  class AuditTrailComponent < ViewComponent::Base
    include ViewHelper

    def initialize(audited_thing:)
      @audited_thing = audited_thing
    end

    def audits
      audits = if audited_thing.is_a? Provider
                 provider_audits
               elsif audited_thing.is_a? ApplicationForm
                 application_audits
               else
                 standard_audits
               end

      if params[:auditable_type]
        audits = audits.where(auditable_type: params[:auditable_type])
      end

      audits.includes(:user).order('created_at desc').page(params[:page] || 1).per(60)
    end

    attr_reader :audited_thing

  private

    def provider_audits
      audited_thing.own_and_associated_audits.unscope(:order).or(
        Audited::Audit.where(
          auditable_type: 'ProviderRelationshipPermissions',
          auditable_id: ProviderRelationshipPermissions.where(ratifying_provider_id: audited_thing.id),
        ),
      )
    end

    def application_audits
      standard_audits.or(
        Audited::Audit.where(
          associated_type: 'ApplicationChoice',
          associated_id: audited_thing.application_choices.map(&:id),
        ),
      )
    end

    def standard_audits
      audited_thing.own_and_associated_audits.unscope(:order)
    end
  end
end
