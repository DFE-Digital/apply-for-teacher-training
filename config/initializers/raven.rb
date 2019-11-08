if Rails.env.production?
  Raven.tags_context(
    azure_host: HostingEnvironment.hostname,
  )
end
