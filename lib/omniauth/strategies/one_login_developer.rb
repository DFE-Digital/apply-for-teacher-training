require 'omniauth'

module OmniAuth
  module Strategies
    class OneLoginDeveloper < Developer
      include OmniAuth::Strategy
    end
  end
end
