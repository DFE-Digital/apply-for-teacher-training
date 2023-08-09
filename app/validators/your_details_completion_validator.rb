class YourDetailsCompletionValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, _application_choice)
    presenter = CandidateInterface::ApplicationFormPresenter.new(record.application_form)

    # on Continuous applications we don't have course choices section
    # anymore
    sections_with_completion = presenter.sections_with_completion.reject { |section| section[0] == :course_choices }

    return if sections_with_completion.map(&:second).all? &&
              presenter.sections_with_validations.map(&:second).all?

    record.errors.add attribute, :incomplete_details
  end
end
