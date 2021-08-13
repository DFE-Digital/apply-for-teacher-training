module ProviderInterface
  class OfferSummaryComponentPreview < ViewComponent::Preview
    layout 'previews/provider'

    def offer_summary
      application_choice = ApplicationChoice.where(status: :offer).limit(5).sample
      course_option = application_choice.current_course_option
      conditions =  application_choice.offer.conditions

      render ProviderInterface::OfferSummaryComponent.new(application_choice: application_choice,
                                                          course: course_option.course,
                                                          course_option: course_option,
                                                          conditions: conditions)
    end
  end
end
