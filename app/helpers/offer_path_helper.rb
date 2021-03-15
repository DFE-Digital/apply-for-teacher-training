module OfferPathHelper
  def offer_path_for(application_choice, step, params = {})
    if step.to_sym == :select_option
      new_provider_interface_application_choice_decision_path(application_choice, params)
    else
      [:new, :provider_interface, application_choice, :offer, step, params]
    end
  end
end
