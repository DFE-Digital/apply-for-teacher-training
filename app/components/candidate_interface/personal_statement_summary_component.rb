module CandidateInterface
  class PersonalStatementSummaryComponent < ApplicationComponent
    MAXIMUM_WORDS_FULL_PERSONAL_STATEMENT = 40
    attr_reader :application_choice
    delegate :unsubmitted?,
             to: :application_choice

    def initialize(application_choice:)
      @application_choice = application_choice
    end

    def call
      personal_statement = if unsubmitted?
                             application_choice.application_form.becoming_a_teacher
                           else
                             application_choice.personal_statement
                           end
      render(ReadMoreReadLessComponent.new(
               personal_statement,
               preview_word_count: MAXIMUM_WORDS_FULL_PERSONAL_STATEMENT,
               show_more_text: 'Show more',
               show_less_text: 'Show less',
             ))
    end
  end
end
