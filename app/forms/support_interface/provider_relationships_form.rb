module SupportInterface
  class ProviderRelationshipsForm
    include ActiveModel::Model

    POSSIBLE_ATTRIBUTES = %w[
      training_provider_can_make_decisions
      ratifying_provider_can_make_decisions
      training_provider_can_view_safeguarding_information
      ratifying_provider_can_view_safeguarding_information
      training_provider_can_view_diversity_information
      ratifying_provider_can_view_diversity_information
    ].freeze

    attr_accessor :relationships
    validate :all_relationships_valid?

    def self.from_models(models)
      new(relationships: models)
    end

    def self.from_params(params)
      # fill the hash with "false" values
      default_values = POSSIBLE_ATTRIBUTES.zip([false].cycle).to_h

      relationships = params.to_h.map do |id, p|
        relationship = ProviderRelationshipPermissions.find(id)
        relationship.assign_attributes(default_values.merge(p))
        if !relationship.setup_at
          relationship.setup_at = Time.zone.now
        end

        relationship
      end

      new(relationships: relationships)
    end

    def save!
      ActiveRecord::Base.transaction do
        @relationships.each(&:save!)
      end
    end

  private

    def all_relationships_valid?
      @relationships.each do |relationship|
        relationship.valid?
        relationship.errors.each do |error|
          errors.add("relationships[#{relationship.id}][#{error.attribute}]", error.message)
        end
      end
    end
  end
end
