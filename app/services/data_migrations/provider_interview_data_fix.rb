module DataMigrations
  class ProviderInterviewDataFix
    TIMESTAMP = 20220720155903
    MANUAL_RUN = false

    def change
      provider = Provider.find_by(name: 'The Manchester Metropolitan University')

      Interview
        .where(provider_id: provider.id)
        .where("location LIKE 'An email%'").each do |interview|
        interview.update_columns(
          location: '',
          additional_details: additional_details_for(interview),
        )
      end
    end

  private

    def additional_details_for(interview)
      if interview.additional_details.blank?
        interview.location
      else
        "#{interview.additional_details} #{interview.location}"
      end
    end
  end
end
