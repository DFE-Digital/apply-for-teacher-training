module AdviserStatus
  extend ActiveSupport::Concern

  def adviser_sign_up
    @adviser_sign_up ||= Adviser::SignUpAvailability.new(current_application)
  end

  included do
    helper_method(:adviser_sign_up)
  end
end
