class ProviderInterface::FindCandidates::PersonalStatementComponent < ApplicationComponent
  MAXIMUM_WORDS_FULL_PERSONAL_STATEMENT = 100
  include ViewHelper

  attr_reader :application_form
  delegate :becoming_a_teacher, :further_information, to: :application_form
  alias_attribute :personal_statement, :becoming_a_teacher

  def initialize(application_form)
    @application_form = application_form
  end

  def call
    render(ReadMoreReadLessComponent.new(personal_statement))
  end
end
