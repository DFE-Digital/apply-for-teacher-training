class PersonalDetailsReviewComponent < ActionView::Component::Base
  validates :application_form, presence: true

  def initialize(application_form:)
    @application_form = application_form
  end

  def rows
    PersonalDetailsReviewPresenter.new(application_form).rows
  end

private

  attr_reader :application_form
end
