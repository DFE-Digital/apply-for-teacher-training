module AzureEnvironment
  def self.authorised_hosts
    ENV.fetch('AUTHORISED_HOSTS').split(',').map(&:strip)
  end

  def self.hostname
    ENV.fetch('CUSTOM_HOSTNAME', authorised_hosts.first)
  end
end
