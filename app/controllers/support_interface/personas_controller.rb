module SupportInterface
  class PersonasController < SupportInterfaceController
    before_action :redirect_unless_test_environment

    def index
      @persona_types = I18n.t('personas.users').keys
    end

  private

    def redirect_unless_test_environment
      return if HostingEnvironment.test_environment?

      redirect_to support_interface_providers_path
    end
  end
end
