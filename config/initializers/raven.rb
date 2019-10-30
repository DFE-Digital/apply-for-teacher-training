if Rails.env.production?
  Raven.tags_context(
    azure_host: AzureEnvironment.hostname,
  )
end
