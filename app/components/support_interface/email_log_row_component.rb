module SupportInterface
  class EmailLogRowComponent < ActionView::Component::Base
    include ViewHelper

    attr_reader :email

    def initialize(email:)
      @email = email
    end
  end
end
