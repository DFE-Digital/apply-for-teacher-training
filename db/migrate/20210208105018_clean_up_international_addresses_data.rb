class CleanUpInternationalAddressesData < ActiveRecord::Migration[6.0]
  def change
    application_forms = ApplicationForm
                        .international
                        .where
                        .not(postcode: nil)

    audit_comment = 'Backfilled while removing the international addresses feature flag. International addresses should not be able to provide a postcode.'

    application_forms.each do |application_form|
      if application_form.address_line4.blank?
        application_form.update!(
          address_line4: application_form.postcode,
          postcode: nil,
          audit_comment: audit_comment,
        )
      else
        application_form.update!(
          address_line4: "#{application_form.address_line4}, #{application_form.postcode}",
          postcode: nil,
          audit_comment: audit_comment,
        )
      end
    end
  end
end
