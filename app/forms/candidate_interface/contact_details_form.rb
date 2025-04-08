module CandidateInterface
  class ContactDetailsForm
    include ActiveModel::Model

    MAX_LENGTH = 50

    attr_accessor :phone_number, :address_line1, :address_line2, :address_line3,
                  :address_line4, :postcode, :address_type, :country

    validates :address_line1, :address_line3, :postcode, presence: true, on: :address, if: :uk?

    validate :address_line1_blank?, on: :address, if: :international?
    validate :address_lines_length_valid?, if: :international?

    validates :address_type, presence: true, on: :address_type
    validates :country, presence: true, on: :address_type, if: :international?

    validates :address_line1, :address_line2, :address_line3, :address_line4,
              length: { maximum: MAX_LENGTH }, on: :address, if: :uk?

    validates :phone_number, phone_number: true, on: :base

    validates :postcode, postcode: true, on: :address, if: :uk?

    def self.build_from_application(application_form)
      new(
        phone_number: application_form.phone_number,
        address_line1: application_form.address_line1,
        address_line2: application_form.address_line2,
        address_line3: application_form.address_line3,
        address_line4: application_form.address_line4,
        postcode: application_form.postcode,
        address_type: application_form.address_type,
        country: application_form.country,
      )
    end

    def save_base(application_form)
      return false unless valid?(:base)

      save(application_form, phone_number:)
    end

    def save_address(application_form)
      return false unless valid?(:address)

      attrs = {
        address_line1:,
        address_line2:,
        address_line3:,
        address_line4:,
        postcode: postcode&.upcase&.strip,
      }
      attrs[:country] = 'GB' if uk?
      save(application_form, attrs)
    end

    def save_address_type(application_form)
      return false unless valid?(:address_type)

      save(
        application_form,
        address_type:,
        country:,
      )
    end

    def uk?
      address_type == 'uk'
    end

    def international?
      address_type == 'international'
    end

    def label_for(attr)
      I18n.t("application_form.contact_details.#{attr}.label.#{address_type}")
    end

    def address_lines
      [address_line1, address_line2, address_line3, address_line4]
    end

    def address_lines_length_valid?
      return false if address_lines.include?(nil)

      address_lines.each.with_index(1) do |value, index|
        value.length > MAX_LENGTH ? errors.add(:"address_line#{index}", :international_too_long, count: MAX_LENGTH) : nil
      end
    end

    def address_line1_blank?
      return false if address_line1.present?

      errors.add(:address_line1, :international_blank)
    end

    def all_errors
      validate(%i[base address address_type])
      errors
    end

    def valid_for_submission?
      all_errors.blank?
    end

  private

    def save(application_form, attributes)
      attributes[:postcode] = nil if international?

      unless valid_for_submission?
        attributes = attributes.merge(contact_details_completed: nil)
      end
      application_form.update(attributes)
    end
  end
end
