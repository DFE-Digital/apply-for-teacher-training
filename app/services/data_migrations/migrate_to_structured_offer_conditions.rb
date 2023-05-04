module DataMigrations
  class MigrateToStructuredOfferConditions
    TIMESTAMP = 20230504152212
    MANUAL_RUN = false

    def change
      OfferCondition.where(type: nil).find_each do |unstructured_condition|
        unstructured_condition.update!(
          type: 'TextCondition',
          details: {
            description: unstructured_condition.text,   
          },
        )
      end
    end
  end
end
