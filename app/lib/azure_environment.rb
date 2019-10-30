module AzureEnvironment
  def self.authorised_hosts
    ENV.fetch('AUTHORISED_HOSTS').split(',').map(&:strip)
  end

  def self.hostname
    hostname = authorised_hosts.first rescue nil
    hostname ||= Socket.gethostname
    ENV.fetch('CUSTOM_HOST_NAME', hostname)
  end
end
