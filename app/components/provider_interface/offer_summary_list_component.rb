module ProviderInterface
  class OfferSummaryListComponent < ActionView::Component::Base
    include ViewHelper
    attr_reader :application_choice, :header

    def initialize(application_choice:, header: 'Your offer')
      @application_choice = application_choice
      @header = header
    end

    def render?
      application_choice.offer.present? || raise(NoOfferError)
    end

    def rows
      [
        {
          key: 'Candidate name',
          value: application_choice.application_form.full_name,
        },
        {
          key: 'Provider',
          value: application_choice.offered_course.provider.name,
        },
        {
          key: 'Course',
          value: application_choice.offered_course.name_and_code,
        },
        {
          key: 'Location',
          value: application_choice.offered_site.name_and_address,
        },
      ]
    end

    class NoOfferError < StandardError; end
  end
end
