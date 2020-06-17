module CandidateInterface
  class ContactDetailsForm
    include ActiveModel::Model

    attr_accessor :phone_number, :address_line1, :address_line2, :address_line3,
                  :address_line4, :postcode, :international_address, :international_address_text
    alias_method :international_address?, :international_address

    validates :address_line1, :address_line3, :postcode, presence: true, on: :address, unless: :international_address?
    validates :international_address_text, presence: true, on: :address, if: :international_address?

    validates :address_line1, :address_line2, :address_line3, :address_line4,
              length: { maximum: 50 }, on: :address

    validates :phone_number, length: { maximum: 50 }, phone_number: true, on: :base

    validates :postcode, postcode: true, on: :address

    def self.build_from_application(application_form)
      new(
        phone_number: application_form.phone_number,
        address_line1: application_form.address_line1,
        address_line2: application_form.address_line2,
        address_line3: application_form.address_line3,
        address_line4: application_form.address_line4,
        postcode: application_form.postcode,
        international_address: application_form.international_address,
        international_address_text: application_form.international_address_text,
      )
    end

    def save_base(application_form)
      return false unless valid?(:base)

      application_form.update(phone_number: phone_number)
    end

    def save_address(application_form)
      return false unless valid?(:address)

      # TODO: Reset international address attributes?

      application_form.update(
        address_line1: address_line1,
        address_line2: address_line2,
        address_line3: address_line3,
        address_line4: address_line4,
        postcode: postcode.upcase,
        country: 'GB',
      )
    end

    def save_international_address(application_form)
      application_form.update(
        international_address: international_address,
      )
    end

    def save_international_address_text(application_form)
      # TODO: Reset structured address attributes?
      # TODO: Extract country from free text?

      application_form.update(
        international_address_text: international_address_text,
      )
    end
  end
end
