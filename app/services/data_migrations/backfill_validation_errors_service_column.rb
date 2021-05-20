module DataMigrations
  class BackfillValidationErrorsServiceColumn
    TIMESTAMP = 20210520104254
    MANUAL_RUN = false

    def change
      ValidationError.update_all(service: 'apply')
    end
  end
end
