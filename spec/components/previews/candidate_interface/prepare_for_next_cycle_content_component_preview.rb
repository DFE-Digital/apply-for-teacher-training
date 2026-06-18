class CandidateInterface::PrepareForNextCycleContentComponentPreview < ViewComponent::Preview
  def find_open
    render PreviewPrepareForNextCycleContentComponent.new(application_form:, find_open: true)
  end

  def find_open_with_course_button
    render PreviewPrepareForNextCycleContentComponent.new(application_form:, find_open: true, show_button: true)
  end

  def find_closed
    render PreviewPrepareForNextCycleContentComponent.new(application_form:)
  end

private

  def application_form
    FactoryBot.build_stubbed(:application_form)
  end

  class PreviewPrepareForNextCycleContentComponent < CandidateInterface::PrepareForNextCycleContentComponent
    def initialize(application_form:, find_open: false, show_button: false)
      super(application_form:)

      @find_open = find_open
      @show_button = show_button
    end

    def after_find_opens?
      @find_open
    end

    def show_button?
      @show_button
    end
  end
end
