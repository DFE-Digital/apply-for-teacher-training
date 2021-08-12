class ProviderRelationshipPermissions < ApplicationRecord
  belongs_to :ratifying_provider, class_name: 'Provider'
  belongs_to :training_provider, class_name: 'Provider'

  PERMISSIONS = %i[make_decisions view_safeguarding_information view_diversity_information].freeze

  validate :at_least_one_active_permission_in_pair, if: -> { setup_at.present? || validation_context == :setup }
  audited associated_with: :training_provider

  scope :providers_have_open_course, lambda {
    course_joins_sql = <<-SQL
      JOIN courses
      ON provider_relationship_permissions.training_provider_id = courses.provider_id
      AND provider_relationship_permissions.ratifying_provider_id = courses.accredited_provider_id
    SQL
    joins(course_joins_sql).merge(Course.current_cycle.open_on_apply).distinct
  }

  def self.all_relationships_for_providers(providers)
    provider_ids = providers.map(&:id)
    table = ProviderRelationshipPermissions.arel_table
    member_of_training_provider = table[:training_provider_id].in(provider_ids)
    member_of_ratifying_provider = table[:ratifying_provider_id].in(provider_ids)
    where(member_of_training_provider.or(member_of_ratifying_provider))
  end

  def self.possible_permissions
    PERMISSIONS.flat_map do |permission|
      ["ratifying_provider_can_#{permission}", "training_provider_can_#{permission}"]
    end
  end

  def partner_organisation(provider)
    return training_provider if provider == ratifying_provider
    return ratifying_provider if provider == training_provider

    nil
  end

  def permit?(permission, provider)
    if provider == training_provider
      send("training_provider_can_#{permission}")
    else
      send("ratifying_provider_can_#{permission}")
    end
  end

  def providers_have_open_course?
    Course.current_cycle.open_on_apply.exists?(provider: training_provider, accredited_provider: ratifying_provider)
  end

private

  def at_least_one_active_permission_in_pair
    PERMISSIONS.each do |permission|
      if !send("training_provider_can_#{permission}") && !send("ratifying_provider_can_#{permission}")
        errors.add(permission, error_message_for_permission(permission))
      end
    end
  end

  def error_message_for_permission(permission)
    permission_description = I18n.t("provider_relationship_permissions.#{permission}.description")
    "Select who can #{permission_description.downcase}"
  end
end
