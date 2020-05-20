class PersonalStatementComponent < ViewComponent::Base
  validates :application_form, presence: true

  delegate :becoming_a_teacher,
           :subject_knowledge,
           :further_information,
           to: :application_form

  def initialize(application_form:)
    @application_form = application_form
  end

private

  attr_reader :application_form
end
