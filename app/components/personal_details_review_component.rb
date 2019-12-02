class PersonalDetailsReviewComponent < ActionView::Component::Base
  validates :application_form, presence: true

  def initialize(application_form:, editable: true, missing_error: false)
    @application_form = application_form
    @personal_details_form = CandidateInterface::PersonalDetailsForm.build_from_application(
      application_form,
    )
    @editable = editable
    @missing_error = missing_error
  end

  def rows
    CandidateInterface::PersonalDetailsReviewPresenter
      .new(form: @personal_details_form)
      .rows
  end

private

  attr_reader :application_form
end
