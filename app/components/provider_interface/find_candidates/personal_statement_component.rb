class ProviderInterface::FindCandidates::PersonalStatementComponent < ViewComponent::Base
  MAXIMUM_WORDS_FULL_PERSONAL_STATEMENT = 100
  include ViewHelper

  attr_reader :application_form
  delegate :becoming_a_teacher, :further_information, to: :application_form
  alias_attribute :personal_statement, :becoming_a_teacher

  def initialize(application_form)
    @application_form = application_form
  end

  def show_full_personal_statement?
    personal_statement.to_s.split.size <= MAXIMUM_WORDS_FULL_PERSONAL_STATEMENT
  end

  def truncated_personal_statement
    personal_statement.truncate_words(
      MAXIMUM_WORDS_FULL_PERSONAL_STATEMENT,
      omission: ' ',
    )
  end

  def remaining_personal_statement_text
    personal_statement[truncated_personal_statement.size..]
  end
end
