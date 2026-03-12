module CandidateInterface
  class PersonalStatementSummaryComponent < ApplicationComponent
    MAXIMUM_WORDS_FULL_PERSONAL_STATEMENT = 40
    attr_reader :application_choice
    delegate :unsubmitted?,
             to: :application_choice

    def initialize(application_choice:)
      @application_choice = application_choice
    end

    def full_personal_statement?
      number_of_words = personal_statement.to_s.split.size

      number_of_words <= MAXIMUM_WORDS_FULL_PERSONAL_STATEMENT
    end

    def personal_statement_short_version
      personal_statement.truncate_words(
        MAXIMUM_WORDS_FULL_PERSONAL_STATEMENT,
        omission: ' ',
      )
    end

    def personal_statement_remaining_version
      personal_statement[personal_statement_short_version.size..]
    end

    def personal_statement
      @personal_statement ||= if unsubmitted?
                                @application_choice.application_form.becoming_a_teacher
                              else
                                @application_choice.personal_statement
                              end
    end
  end
end
