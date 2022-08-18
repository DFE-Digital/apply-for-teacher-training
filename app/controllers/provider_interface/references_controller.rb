module ProviderInterface
  class ReferencesController < ProviderInterfaceController
    before_action :set_application_choice

    def index
      @references = @application_choice.application_form.application_references
    end
  end
end
