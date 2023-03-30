# Enabling PostgreSQL extensions

There a few steps required in order for postgresql extensions to be correctly enabled

### Generate a new migration
`rails g migration EnableExample`

After the migration has been generated populate it with the following:
```ruby
class EnableExample < ActiveRecord::Migration[7.0]
  def change
    enable_extension 'example' unless extension_enabled?('example')
  end
end
```

### Update the azure config
In `terraform/modules/kubernetes/azure_postgres.tf` add your extension to the following resource:
```
azurerm_postgresql_flexible_server_configuration" "postgres-extensions {
	count =
	name =
	server_d =
	value = "EXAMPLE_EXTENSION_HERE"
}
```
