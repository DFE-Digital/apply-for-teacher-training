module ProviderInterface
  class StatusBoxComponentPreview < ViewComponent::Preview
    include PreviewProviderHelper

    layout 'previews/provider'

    # This component is set to render: false
    # def awaiting_provider_decision
    #   render ProviderInterface::StatusBoxComponent.new(
    #     application_choice: FactoryBot.build_stubbed(:application_choice, status: :awaiting_provider_decision, course_option:),
    #   )
    # end

    # There is no ProviderInterface::StatusBoxComponents::OfferComponent
    # def offer
    #   render ProviderInterface::StatusBoxComponent.new(
    #     application_choice: FactoryBot.build_stubbed(
    #       :application_choice,
    #       status: :offer,
    #       offer: FactoryBot.build_stubbed(:offer),
    #       course_option:,
    #     ),
    #   )
    # end

    def pending_conditions_with_conditions
      render ProviderInterface::StatusBoxComponent.new(
        application_choice: FactoryBot.build_stubbed(
          :application_choice,
          status: :pending_conditions,
          offer: FactoryBot.build_stubbed(:offer),
          course_option:,
        ),
      )
    end

    def pending_conditions_with_no_conditions
      render ProviderInterface::StatusBoxComponent.new(
        application_choice: FactoryBot.build_stubbed(
          :application_choice,
          status: :pending_conditions,
          offer: FactoryBot.build_stubbed(:unconditional_offer),
          course_option:,
        ),
      )
    end

    # There is no ProviderInterface::StatusBoxComponents::RejectedComponent
    # def rejected
    #   render ProviderInterface::StatusBoxComponent.new(
    #     application_choice: FactoryBot.build_stubbed(
    #       :application_choice,
    #       status: :rejected,
    #       course_option:,
    #     ),
    #   )
    # end

    def recruited
      render ProviderInterface::StatusBoxComponent.new(
        application_choice: FactoryBot.build_stubbed(
          :application_choice,
          status: :recruited,
          recruited_at: Time.zone.now,
          course_option:,
          offer: FactoryBot.build_stubbed(:unconditional_offer),
        ),
      )
    end

    def declined
      render ProviderInterface::StatusBoxComponent.new(
        application_choice: FactoryBot.build_stubbed(
          :application_choice,
          status: :declined,
          declined_at: Time.zone.now,
          course_option:,
          offer: FactoryBot.build_stubbed(:unconditional_offer),
        ),
      )
    end

    def conditions_not_met
      render ProviderInterface::StatusBoxComponent.new(
        application_choice: FactoryBot.build_stubbed(
          :application_choice,
          status: :conditions_not_met,
          course_option:,
          offer: FactoryBot.build_stubbed(:offer, :with_unmet_conditions),
        ),
      )
    end

    # This component is set to render: false
    # def application_withdrawn
    #   render ProviderInterface::StatusBoxComponent.new(
    #     application_choice: FactoryBot.build_stubbed(
    #       :application_choice,
    #       status: :withdrawn,
    #       course_option:,
    #     ),
    #   )
    # end

    def offer_withdrawn
      render ProviderInterface::StatusBoxComponent.new(
        application_choice: FactoryBot.build_stubbed(
          :application_choice,
          status: :offer_withdrawn,
          offer_withdrawn_at: Time.zone.now,
          course_option:,
          offer: FactoryBot.build_stubbed(:unconditional_offer),
        ),
      )
    end

  private

    def provider
      @provider ||= FactoryBot.create(:provider, code: unique_provider_code)
    end

    def course
      @course ||= FactoryBot.create(:course, provider:)
    end

    def course_option
      @course_option ||= FactoryBot.create(:course_option, course: course)
    end
  end
end
