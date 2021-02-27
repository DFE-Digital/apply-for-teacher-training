module SupportInterface
  class AuditTrailItemComponent < ViewComponent::Base
    include ViewHelper

    def initialize(audit:)
      @audit = audit
    end

    def audit_entry_event_label
      if audit.comment.present? && audit.audited_changes.empty?
        "Comment on #{audit.auditable_type.titlecase}"
      elsif audit.auditable_type == 'ProviderPermissions'
        label_for_provider_permission_change(audit)
      elsif audit.auditable_type == 'ProviderRelationshipPermissions'
        label_for_provider_relationship_permission_change(audit)
      else
        "#{audit.action.capitalize} #{audit.auditable_type.titlecase} ##{audit.auditable_id}"
      end
    end

    def audit_entry_user_label
      if audit.user_type == 'Candidate'
        "#{audit.user.email_address} (Candidate)"
      elsif audit.user_type == 'ApplicationReference'
        if audit.user
          "#{audit.user.name} - #{audit.user.email_address} (Referee)"
        else
          'Deleted referee'
        end
      elsif audit.user_type == 'VendorApiUser'
        "#{audit.user.email_address} (Vendor API)"
      elsif audit.user_type == 'SupportUser'
        "#{audit.user.email_address} (Support user)"
      elsif audit.user_type == 'ProviderUser'
        "#{audit.user.email_address} (Provider user)"
      elsif audit.username.present?
        audit.username
      else
        '(Unknown User)'
      end
    end

    def changes
      audit.audited_changes.merge(comment_change).reject { |_, values| values.blank? }
    end

    def comment_change
      { 'comment' => audit.comment }
    end

    attr_reader :audit

  private

    def label_for_provider_permission_change(audit)
      case audit.action
      when 'create'
        provider = Provider.find(audit.audited_changes['provider_id'])
        "Access granted for #{provider.name}"
      when 'update'
        # permissions record may not exist, user no longer associated with provider
        provider = ProviderPermissions.find_by(id: audit.auditable_id)&.provider
        provider_name = if provider
                          provider.name
                        else
                          creation_record = Audited::Audit.find_by(
                            auditable_type: 'ProviderPermissions',
                            auditable_id: audit.auditable_id,
                            action: 'create',
                          )

                          if creation_record
                            Provider.find_by(id: creation_record.audited_changes['provider_id']).name
                          else
                            'a provider'
                          end
                        end
        "Permissions changed for #{provider_name}"
      when 'destroy'
        provider = Provider.find(audit.audited_changes['provider_id'])
        "Access revoked for #{provider.name}"
      end
    end

    def label_for_provider_relationship_permission_change(audit)
      training_provider = audit.auditable.training_provider
      ratifying_provider = audit.auditable.ratifying_provider

      case audit.action
      when 'create'
        "Permission relationship between training provider #{training_provider.name} and ratifying provider #{ratifying_provider.name} created"
      when 'update'
        "Permission relationship between training provider #{training_provider.name} and ratifying provider #{ratifying_provider.name} changed"
      end
    end
  end
end
