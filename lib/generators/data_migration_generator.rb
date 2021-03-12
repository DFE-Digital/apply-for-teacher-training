class DataMigrationGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)

  desc 'This generates a data migration service in app/services/data_migrations and adds it to the data migration rake task'
  def create_data_migration_file
    name = "DataMigrations::#{file_name.camelize}"
    copy_file 'data_migration.rb.tt', "app/services/data_migrations/#{file_name}.rb"
    gsub_file "app/services/data_migrations/#{file_name}.rb", '%{service_name}', file_name.camelize
    gsub_file "app/services/data_migrations/#{file_name}.rb", '%{timestamp}', Time.zone.now.to_s(:number)

    copy_file 'data_migration_spec.rb.tt', "spec/services/data_migrations/#{file_name}_spec.rb"
    gsub_file "spec/services/data_migrations/#{file_name}_spec.rb", '%{service_name}', file_name.camelize

    inject_into_file 'lib/tasks/data.rake', "  '#{name}',\n", after: "# do not delete or edit this line - services added below by generator\n"
  end
end
