class ServiceUnavailableComponent < ViewComponent::Base
  def initialize; end

  def title_content
    HostingEnvironment.sandbox_mode? ? t('service_unavailable.sandbox_title') : t('service_unavailable.title')
  end

  def downtime_content
    HostingEnvironment.sandbox_mode? ? t('service_unavailable.sandbox_downtime') : t('service_unavailable.downtime')
  end
end
