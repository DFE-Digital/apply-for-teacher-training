class ProviderRelationshipPermissionsPair
  attr_reader :ratifying_provider_permissions, :training_provider_permissions

  def initialize(ratifying_provider_permissions:, training_provider_permissions:)
    @ratifying_provider_permissions = ratifying_provider_permissions
    @training_provider_permissions = training_provider_permissions
  end

  def self.pairs_from_collection(collection)
    collection.group_by { |p| [p.ratifying_provider_id, p.training_provider_id] }.map do |_key, ary|
      new(
        ratifying_provider_permissions: ary.find { |prp| prp.type == 'RatifyingProviderPermissions' },
        training_provider_permissions: ary.find { |prp| prp.type == 'TrainingProviderPermissions' },
      )
    end
  end
end
