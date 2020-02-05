module ProviderInterface
  class EditResponseOptionsComponent < ActionView::Component::Base
    attr_accessor :form

    def initialize(form:)
      self.form = form
    end

    OPTIONS = [
      OpenStruct.new(
        value: 'different_course',
        name: 'Offer a different course',
        description: 'Include any conditions or recommendations',
      ),
      OpenStruct.new(
        value: 'withdraw_offer',
        name: 'Withdraw offer',
      ),
    ].freeze

    def options
      OPTIONS
    end
  end
end
