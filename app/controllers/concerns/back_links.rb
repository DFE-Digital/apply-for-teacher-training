# Includes methods to all controllers using backlinks
#
# Usage:
#   include BackLinks
#
#   def edit
#     @return_to = return_to_after_edit(default: candidate_interface_interview_preferences_show_path)
#   end
#
#
#  when a user visits a resource we generate a back link
#
#
module BackLinks
  extend ActiveSupport::Concern

  def return_to_after_edit(default:)
    if redirect_back_to_application_review_page?
      { back_path: candidate_interface_application_review_path, params: redirect_back_to_application_review_page_params }
    else
      { back_path: default, params: {} }
    end
  end

  def redirect_back_to_application_review_page_params
    { 'return-to' => 'application-review' }
  end

  def redirect_back_to_application_review_page?
    params['return-to'] == 'application-review' || params[:return_to] == 'application-review'
  end

private

  def application_form_path
    if current_application.continuous_applications?
      if request.path.match?(/withdraw/)
        candidate_interface_continuous_applications_choices_path
      else
        candidate_interface_continuous_applications_details_path
      end
    elsif !current_application.submitted?
      candidate_interface_application_form_path
    elsif current_application.submitted?
      candidate_interface_application_review_submitted_path
    end
  end

  included do
    helper_method :application_form_path
  end
end
