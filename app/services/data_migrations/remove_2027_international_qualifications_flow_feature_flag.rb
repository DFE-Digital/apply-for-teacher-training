module DataMigrations
  class Remove2027InternationalQualificationsFlowFeatureFlag
    TIMESTAMP = 20260929101944
    MANUAL_RUN = false

    def change
      Feature.find_by(name: '2027_international_qualifications_flow')&.destroy
      Feature.find_by(name: '2027_application_form_contact_details_residency_questions')&.destroy
    end
  end
end
