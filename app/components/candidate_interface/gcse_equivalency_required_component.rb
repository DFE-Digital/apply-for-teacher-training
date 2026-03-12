class CandidateInterface::GcseEquivalencyRequiredComponent < ApplicationComponent
  attr_accessor :application_choice, :missing_uk_gcses, :accept_english_gcse_equivalency, :accept_maths_gcse_equivalency, :accept_science_gcse_equivalency

  def initialize(application_choice, missing_uk_gcses)
    @application_choice = application_choice
    @missing_uk_gcses = missing_uk_gcses
    @accept_english_gcse_equivalency = application_choice.course.accept_english_gcse_equivalency?
    @accept_maths_gcse_equivalency = application_choice.course.accept_maths_gcse_equivalency?
    @accept_science_gcse_equivalency = application_choice.course.accept_science_gcse_equivalency?
  end

  def provider_accepts_equivalencies_and_gcse_is_missing?
    missing_gcse_subjects = missing_uk_gcses.map(&:subject)

    accepted_equivalency_subjects = []
    accepted_equivalency_subjects << 'english' if accept_english_gcse_equivalency
    accepted_equivalency_subjects << 'maths' if accept_maths_gcse_equivalency
    accepted_equivalency_subjects << 'science' if accept_science_gcse_equivalency

    missing_gcse_subjects.all? { |missing_subject| accepted_equivalency_subjects.include?(missing_subject) }
  end

private

  def no_qualifications_text
    subjects = missing_uk_gcses.map(&:subject)
    subjects[0] = subjects[0].capitalize if subjects[0] == 'english'
    subjects.to_sentence(last_word_connector: ' and ', two_words_connector: ' and ')
  end

  def course_accepted_equivalencies_text
    subjects = []
    subjects << 'English' if accept_english_gcse_equivalency
    subjects << 'maths' if accept_maths_gcse_equivalency
    subjects << 'science' if accept_science_gcse_equivalency

    subjects.to_sentence(last_word_connector: ' and ', two_words_connector: ' and ')
  end
end
