class ProviderInterface::FindCandidates::ApplicationChoicesComponent < ViewComponent::Base
  attr_reader :application_form

  def initialize(application_form:)
    @application_form = application_form
  end

  def course_address(choice)
    site = choice.course_option.site
    "#{site.address_line2} #{site.address_line3}"
  end

  def rejection_reason_value(choice)
    return unless rejection_reasons_text(choice)

    rejection_reasons_text(choice)
  end

private

  def rejection_reasons_text(choice)
    return unless choice.rejection_reason.present? || choice.structured_rejection_reasons.present?

    @rejection_reasons_text ||= render(RejectionsComponent.new(application_choice: choice))
  end
end
