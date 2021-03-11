# Data migrations

In order to be able to test, track and if required, remove from the codebase data migrations, we have decided to add a rake task to manage this in a consistent way. Along with the rake task, a complimentary generator has been added that creates and configures the service to be used for each data migration.

## How to use this service

### Generating a new data migration service

`rails g data_migration NAME`

For example, running `rails generate data_migration backfill_data` will generate a new data migration service `DataMigrations::BackfillData` in `app/services/data_migrations`, similar to the example displayed below.

```ruby
module DataMigrations
  class BackfillData
    TIMESTAMP = 20210311005059
    MANUAL_RUN = false

    def change
      # add any changes here
    end
  end
end
```

### Running a data migration manually

If you want to control over when the data migration is executed, `MANUAL_RUN` must be set to true.
The service can then be executed manually from the terminal

`rake data:migrate:manual[DataMigrations::BackfillData]`

### Removing a service

To remove a data migration service

1. Delete the file and corresponding spec
2. Remove the line referencing the service from the rake task found at `/lib/tasks/data.rake` (make sure to delete the entire line and not to introduce any space, or change the `DATA_MIGRATION_SERVICES` array structure)

### Tracking executed services

You can retrieve information about executed services by quering the `DataMigration` model.
