module DataMigrations
  class ModifyDigitalEmailAddresses
    TIMESTAMP = 20230427174430
    MANUAL_RUN = false

    def change
      SupportUser.where("email_address LIKE '%@digital.education.gov.uk'").each do |support_user|
        new_email = support_user.email_address.gsub(
          '@digital.education.gov.uk',
          '@education.gov.uk',
        )
        support_user.update(email_address: new_email)
      end
    end
  end
end
