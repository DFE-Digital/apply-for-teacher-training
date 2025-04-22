module SupportInterface
  module ApplicationForms
    class EditReferenceDetailsForm
      include ActiveModel::Model

      attr_accessor :name, :email_address, :relationship, :audit_comment, :confidential

      validates :name, presence: true, length: { minimum: 2, maximum: 200 }
      validates :email_address, presence: true, valid_for_notify: true, length: { maximum: 100 }
      validates :relationship, presence: true, word_count: { maximum: 50 }
      validates :audit_comment, presence: true
      validates :confidential, presence: true

      def self.build_from_reference(reference)
        new(
          name: reference.name,
          email_address: reference.email_address,
          relationship: reference.relationship,
          confidential: reference.confidential,
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
            confidential: ActiveModel::Type::Boolean.new.cast(confidential),
          )
        end
      end
    end
  end
end
