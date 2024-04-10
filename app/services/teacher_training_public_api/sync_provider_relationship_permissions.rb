module TeacherTrainingPublicAPI
  class SyncProviderRelationshipPermissions
    def self.verify_outdated_provider_relationship_permissions
      providers = ::Provider.with_courses.where("courses.recruitment_cycle_year = #{::RecruitmentCycle.current_year}")
      records_to_be_deleted = []

      providers.find_each do |provider|
        records_to_be_deleted << SyncProviderRelationshipPermissions.new(provider).records_to_be_deleted
      end

      records_to_be_deleted.flatten.compact
    end

    def initialize(provider)
      @provider = provider
    end

    def records_to_be_deleted
      return if accredited_providers.blank?

      @provider.ratifying_provider_permissions.select do |permission|
        permission.training_provider.code.exclude?(accredited_providers)
      end
    end

    def accredited_providers
      @provider.courses.map(&:accredited_provider).compact.uniq.map(&:code)
    end

    def call
      return unless FeatureFlag.active?(:sync_provider_relationship_permission)

      ActiveRecord::Base.transaction do
        records_to_be_deleted.map(&:destroy)
      end
    end
  end
end
