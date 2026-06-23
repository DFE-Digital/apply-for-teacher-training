class CandidateInterface::ApplicationChoices::JanuaryStartContentComponentPreview < ViewComponent::Preview
  def default
    render PreviewJanuaryStartContentComponent.new(application_form:)
  end

private

  def application_form
    @application_form ||= FactoryBot.create(:application_form)
  end

  class PreviewJanuaryStartContentComponent < CandidateInterface::ApplicationChoices::JanuaryStartContentComponent
    def application_choices
      @application_choices ||= begin
        provider = FactoryBot.build(:provider, code:)
        course = FactoryBot.build(:course, provider:)
        course_option = FactoryBot.build(:course_option, course: course)
        FactoryBot.create(:application_choice, application_form:, course_option:)

        CandidateInterface::SortApplicationChoices.call(
          application_choices: @application_form.application_choices.for_sorting,
        )
      end
    end

    def code
      loop do
        random_code = SecureRandom.alphanumeric(3)
        break unless Provider.exists?(code: random_code)
      end
      random_code
    end
  end
end
