module SupportInterface
  module ApplicationForms
    class RevertRejectionForm
      include ActiveModel::Model

      attr_accessor :accept_guidance, :audit_comment_ticket

      validates :accept_guidance, :audit_comment_ticket, presence: true
      validates_with ZendeskUrlValidator

      def save(application_choice)
        self.accept_guidance = ActiveModel::Type::Boolean.new.cast(accept_guidance)

        return false unless valid?
        return false if duplicate_application_for_course?(application_choice)

        SupportInterface::RevertRejection.new(
          application_choice:,
          zendesk_ticket: audit_comment_ticket,
        ).save!
      end

    private

      def duplicate_application_for_course?(application_choice)
        validator = ReapplyValidator.new
        application_choice.status = :awaiting_provider_decision
        validator.validate(application_choice)

        if application_choice.errors.any?
          errors.add(:base, :duplicate)
          true
        else
          false
        end
      end
    end
  end
end
