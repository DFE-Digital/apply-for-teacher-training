if ENV.key?('VCAP_APPLICATION')
  vcap_config = JSON.parse(ENV['VCAP_APPLICATION'])
  app_name = vcap_config['name']
  app_guid = vcap_config['application_id']
  org_name = vcap_config['organization_name']
  space_name = vcap_config['space_name']
  app_instance = ENV['CF_INSTANCE_INDEX']

  Yabeda.configure do
    default_tag :app, app_name
    default_tag :guid, app_guid
    default_tag :exported_instance, app_instance
    default_tag :organisation, org_name
    default_tag :space, space_name
  end
end

# Custom metrics
Yabeda.configure do
  group :apply_db do
    gauge :application_choices,  comment: "Number of application choices in database"
  end

  collect do
    apply_db.application_choices.set({}, ApplicationChoice.count)
  end
end
