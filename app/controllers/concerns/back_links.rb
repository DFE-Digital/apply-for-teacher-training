# Helper methods relating to backlinks
#
module BackLinks
  extend ActiveSupport::Concern

  def return_to_after_edit(default:)
    { back_path: default, params: {} }
  end

  # Method to determine the path to the candidates current dashboard based on
  # contextual information.

  def application_form_path
    # `current_application` is a `helper_method` defined in CandidateInterfaceController
    # It's not available in view specs
    return '' unless defined?(current_application)

    if request.path.match?(/withdraw/)
      candidate_interface_application_choices_path
    else
      candidate_interface_details_path
    end
  end

  module_function :application_form_path

  included do
    helper_method :application_form_path
  end
end
