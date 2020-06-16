module ProviderInterface
  class EmailLogRowComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :email

    def initialize(email:)
      @email = email
    end

    def summary_list_rows
      [
        { key: 'To', value: email.to },
        { key: 'Subject', value: email.subject.inspect },
      ]
    end
  end
end
