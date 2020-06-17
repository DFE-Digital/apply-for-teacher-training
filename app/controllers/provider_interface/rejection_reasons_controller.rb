module ProviderInterface
  class RejectionReasonsController < ProviderInterfaceController
    def new
      @reasons_form = RejectionReasonsForm.new
      @reasons_form.begin!
    end

    def create
      @reasons_form = RejectionReasonsForm.new(form_params)
      if @reasons_form.valid?
        @reasons_form.next_step!
        if @reasons_form.done?
          render inline: "<code>#{params.inspect}</code>"
        else
          render :new
        end
      else
        render :new
      end
    end

    def form_params
      params.require('provider_interface_rejection_reasons_form')
        .permit(:alternative_rejection_reason, questions_attributes: {})
    end
  end
end
