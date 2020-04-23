module ProviderInterface
  class VolunteeringHistoryComponent < ViewComponent::Base
    validates :application_form, presence: true

    def initialize(application_form:)
      self.application_form = application_form
    end

    def history
      @history ||= @application_form.application_volunteering_experiences
    end

    def render?
      history.present?
    end

  private

    attr_accessor :application_form
  end
end
