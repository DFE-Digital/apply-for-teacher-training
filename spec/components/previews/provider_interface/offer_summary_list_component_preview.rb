module ProviderInterface
  class OfferSummaryListComponentPreview < ViewComponent::Preview
    include PreviewProviderHelper

    layout 'previews/provider'

    def application_choice_with_offer
      render ProviderInterface::OfferSummaryListComponent.new(
        application_choice: FactoryBot.create(:application_choice, status: :offer, course_option:, application_form:),
      )
    end

    def application_choice_without_offer
      render ProviderInterface::OfferSummaryListComponent.new(
        application_choice: FactoryBot.create(
          :application_choice,
          status: :awaiting_provider_decision,
          course_option:,
          application_form:,
        ),
      )
    end

  private

    def application_form
      @application_form ||= FactoryBot.build(:completed_application_form)
    end

    def provider
      @provider ||= FactoryBot.build(:provider, code: unique_provider_code)
    end

    def course
      @course ||= FactoryBot.build(:course, provider:)
    end

    def course_option
      @course_option ||= FactoryBot.build(:course_option, course: course)
    end
  end
end
