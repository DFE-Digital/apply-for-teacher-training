module SupportInterface
  class PersonasController < SupportInterfaceController
    def index
      @persona_types = I18n.t('personas.users').keys
    end
  end
end
