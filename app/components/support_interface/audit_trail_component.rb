module SupportInterface
  class AuditTrailComponent < ViewComponent::Base
    include ViewHelper

    validates :audited_thing, presence: true

    def initialize(audited_thing:)
      @audited_thing = audited_thing
    end

    def audits
      unscoped_audits.includes(:user).order(id: :desc).page(params[:page] || 1).per(60)
    end

    def filter
      @filter ||= AuditTrailFilter.new(
        params: request.params,
        unscoped_audits: unscoped_audits,
      )
    end

    attr_reader :audited_thing

  private

    def unscoped_audits
      if audited_thing.is_a? Provider
        audits_for_provider
      else
        standard_audits
      end
    end

    def audits_for_provider
      standard_audits.or(Audited::Audit.where(
                           auditable_type: 'ProviderRelationshipPermissions',
                           auditable_id: ProviderRelationshipPermissions.where(ratifying_provider_id: audited_thing.id),
                         ))
    end

    def standard_audits
      audited_thing.own_and_associated_audits.unscope(:order)
    end

    class AuditTrailFilter
      attr_reader :applied_filters

      def initialize(params:, unscoped_audits:)
        @applied_filters = params
        @unscoped_audits = unscoped_audits
      end

      def filters
        @filters ||= [auditable_type]
      end

    private

      def auditable_type
        options = @unscoped_audits.distinct(:auditable_type).pluck(:auditable_type).sort.map do |auditable_type|
          {
            value: auditable_type,
            label: auditable_type,
            checked: applied_filters[:auditable_type]&.include?(auditable_type),
          }
        end

        {
          type: :checkboxes,
          heading: 'Change type',
          name: 'auditable_type',
          options: options,
        }
      end
    end
  end
end
