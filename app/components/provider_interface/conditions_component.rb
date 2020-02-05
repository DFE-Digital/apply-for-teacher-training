module ProviderInterface
  class ConditionsComponent < ActionView::Component::Base
    include ViewHelper

    attr_reader :application_choice

    def initialize(application_choice:)
      @application_choice = application_choice
    end

    def conditions
      @application_choice.offer['conditions']
    end

    def condition_rows
      if conditions.empty?
        [{ value: 'No conditions have been specified' }]
      else
        conditions.map { |condition| { value: condition } }
      end
    end
  end
end
