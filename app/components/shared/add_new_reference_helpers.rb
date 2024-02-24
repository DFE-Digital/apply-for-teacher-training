module AddNewReferenceHelpers
  include ViewHelper

  def options_for_add_reference_link
    if application_form.complete_references_information?
      { secondary: true }
    else
      {}
    end
  end
end
