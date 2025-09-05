module ProviderInterface
  class EditResponseOptionsComponent < ApplicationComponent
    attr_accessor :form

    def initialize(form:)
      self.form = form
    end

    OPTIONS = [
      Struct.new(:value, :name)
            .new('different_course', 'Offer a different course'),
      Struct.new(:value, :name)
            .new('withdraw_offer', 'Withdraw offer'),
    ].freeze

    def options
      OPTIONS
    end
  end
end
