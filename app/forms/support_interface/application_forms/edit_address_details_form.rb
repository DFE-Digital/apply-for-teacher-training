module SupportInterface
  module ApplicationForms
    class EditAddressDetailsForm
      include ActiveModel::Model

      attr_accessor :address_line1, :address_line2, :address_line3,
                    :address_line4, :postcode, :address_type, :country, :international_address, :audit_comment

      validates :address_line1, :address_line3, :postcode, presence: true, on: :address, if: :uk?
      validates :international_address, presence: true, on: :address, if: :international?
      validates :address_type, presence: true, on: :address_type
      validates :country, presence: true, on: :address_type, if: :international?

      validates :address_line1, :address_line2, :address_line3, :address_line4,
                length: { maximum: 50 }, on: :address

      validates :postcode, postcode: true, on: :address
      validates :audit_comment, presence: true, on: :address

      def self.build_from_application_form(application_form)
        new(
          address_line1: application_form.address_line1,
          address_line2: application_form.address_line2,
          address_line3: application_form.address_line3,
          address_line4: application_form.address_line4,
          postcode: application_form.postcode,
          address_type: application_form.address_type || 'GB',
          country: application_form.country,
          international_address: application_form.international_address,
          audit_comment: application_form.audit_comment,
        )
      end

      def save_address(application_form)
        return false unless valid?(:address)

        if uk?
          application_form.update!(
            address_line1: address_line1,
            address_line2: address_line2,
            address_line3: address_line3,
            address_line4: address_line4,
            postcode: postcode&.upcase,
            country: 'GB',
            international_address: nil,
            audit_comment: audit_comment,
          )
        else
          application_form.update(
            address_line1: nil,
            address_line2: nil,
            address_line3: nil,
            address_line4: nil,
            postcode: nil,
            international_address: international_address,
            audit_comment: audit_comment,
          )
        end
      end

      def save_address_type(application_form)
        return false unless valid?(:address_type)

        application_form.update(
          address_type: address_type,
          country: country.presence || 'GB',
        )
      end

      def uk?
        address_type == 'uk'
      end

      def international?
        address_type == 'international'
      end
    end
  end
end
