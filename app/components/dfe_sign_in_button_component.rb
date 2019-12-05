class DfESignInButtonComponent < ActionView::Component::Base
  include ViewHelper
  attr_accessor :bypass

  def initialize(bypass:)
    self.bypass = bypass
  end

  def title
    bypass ? 'Sign in using DfE Sign-in (bypass)' : 'Sign in using DfE Sign-in'
  end

  def path
    bypass ? '/auth/developer' : '/auth/dfe'
  end
end
