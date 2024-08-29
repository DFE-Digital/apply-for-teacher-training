module DataMigrations
  class SetSelectableSchoolsOnProviders
    TIMESTAMP = 20240829150421
    MANUAL_RUN = false

    def change
      provider_codes = %w[E65 2CG 2CH 2CJ 2CK 2C1 1EX 1QU CS01 2X4 1ZO]
      Provider.where(code: provider_codes).update_all(selectable_school: true)
    end
  end
end
