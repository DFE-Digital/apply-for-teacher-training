module DataMigrations
  class PopulateApplicationChoiceProviderIds
    TIMESTAMP = 20210819144725
    MANUAL_RUN = true

    def change
      ApplicationChoice.find_each(batch_size: 100) do |application_choice|
        provider_ids = [
          application_choice.provider&.id,
          application_choice.accredited_provider&.id,
          application_choice.current_provider&.id,
          application_choice.current_accredited_provider&.id,
        ].compact.uniq

        application_choice.update_columns(provider_ids: provider_ids) or
          raise "Unable to update ApplicationChoice ##{application_choice.id}"
      end
    end
  end
end
