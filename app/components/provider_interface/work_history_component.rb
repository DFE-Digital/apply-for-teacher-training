module ProviderInterface
  class WorkHistoryComponent < ActionView::Component::Base
    validates :application_form, presence: true

    def initialize(application_form:)
      self.application_form = application_form
    end

    def work_history_with_breaks
      []
    end

  private

    attr_accessor :application_form
  end
end
