module ProviderInterface
  class OfferSummaryComponentPreview < ViewComponent::Preview
    include PreviewProviderHelper

    layout 'previews/provider'

    def offer_summary
      render ProviderInterface::OfferSummaryComponent.new(application_choice:,
                                                          course:,
                                                          course_option:,
                                                          conditions: offer.conditions)
    end

  private

    def application_choice
      @application_choice ||= FactoryBot.build_stubbed(
        :application_choice,
        status: :pending_conditions,
        offer:,
        course_option:,
        application_form:,
      )
    end

    def offer
      @offer ||= FactoryBot.build_stubbed(:offer)
    end

    def application_form
      @application_form ||= FactoryBot.build(:completed_application_form)
    end

    def provider
      @provider ||= FactoryBot.build(:provider, code: unique_provider_code)
    end

    def course
      debugger
      @course ||= FactoryBot.build(:course, provider:)
    end

    def course_option
      @course_option ||= FactoryBot.build(:course_option, course: course)
    end
  end
end
