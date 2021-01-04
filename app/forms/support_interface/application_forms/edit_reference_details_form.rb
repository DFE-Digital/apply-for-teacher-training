module SupportInterface
  module ApplicationForms
    class EditReferenceDetailsForm
      include ActiveModel::Model
      include ValidationUtils

      attr_accessor :name, :email_address, :relationship, :audit_comment

      validates :name, presence: true, length: { minimum: 2, maximum: 200 }
      validates :email_address, presence: true, valid_for_notify: true, length: { maximum: 100 }
      validates :relationship, presence: true, word_count: { maximum: 50 }
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

        reference.update!(
          name: name,
          email_address: email_address,
          relationship: relationship,
          audit_comment: audit_comment,
        )
      end
    end
  end
end
