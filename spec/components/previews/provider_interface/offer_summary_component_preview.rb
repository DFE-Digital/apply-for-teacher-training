module ProviderInterface
  class OfferSummaryComponentPreview < ViewComponent::Preview
    layout 'previews/provider'

    def offer_summary
      application_choice = ApplicationChoice.limit(5).sample
      course_option = CourseOption.limit(10).sample
      conditions =  MakeOffer::STANDARD_CONDITIONS + ['Driving license']

      render ProviderInterface::OfferSummaryComponent.new(application_choice: application_choice,
                                                          course_option: course_option,
                                                          conditions: conditions)
    end
  end
end
