module SupportInterface
  module ApplicationForms
    class EditReferenceDetailsForm
      include ActiveModel::Model

      attr_accessor :name, :email_address, :relationship, :audit_comment

      validates :name, presence: true, length: { minimum: 2, maximum: 200 }
      validates :email_address, presence: true, valid_for_notify: true, length: { maximum: 100 }
      validates :relationship, presence: true, length: { maximum: 500 }
      validates :audit_comment, presence: true

      def self.build_from_reference(reference)
        new(
          name: reference.name,
          email_address: reference.email_address,
          relationship: reference.relationship,
        )
      end

      def save(reference)
        return false unless valid?

        ApplicationForm.with_unsafe_application_choice_touches do
          reference.update!(
            name:,
            email_address:,
            relationship:,
            audit_comment:,
          )
        end
      end
    end
  end
end
