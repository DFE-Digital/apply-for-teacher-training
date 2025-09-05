module SupportInterface
  class AuditTrailComponent < ApplicationComponent
    include Pagy::Backend
    include ViewHelper

    PAGY_PER_PAGE = 10

    def initialize(audited_thing:)
      @audited_thing = audited_thing
    end

    def audits
      audits = fetch_audits_by_type

      if params[:auditable_type]
        audits = audits.where(auditable_type: params[:auditable_type])
      end

      audits.includes(:user).order(created_at: :desc)
    end

    def before_render
      @pagy, @items = pagy(audits, limit: PAGY_PER_PAGE)
    end

    attr_reader :audited_thing

  private

    def fetch_audits_by_type
      case audited_thing
      when Provider
        provider_audits
      when ApplicationForm
        application_audits
      else
        standard_audits
      end
    end

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
