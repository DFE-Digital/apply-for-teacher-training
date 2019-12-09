module CandidateInterface
  class ContactDetailsForm
    include ActiveModel::Model

    attr_accessor :phone_number, :address_line1, :address_line2, :address_line3,
                  :address_line4, :postcode

    validates :address_line1, :address_line3, :postcode, presence: true, on: :address

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
      )
    end

    def save_base(application_form)
      return false unless valid?(:base)

      application_form.update(phone_number: phone_number)
    end

    def save_address(application_form)
      return false unless valid?(:address)

      application_form.update(
        address_line1: address_line1,
        address_line2: address_line2,
        address_line3: address_line3,
        address_line4: address_line4,
        postcode: postcode,
        country: 'UK',
      )
    end
  end
end
