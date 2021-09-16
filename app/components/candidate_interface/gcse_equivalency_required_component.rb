class CandidateInterface::GcseEquivalencyRequiredComponent < ViewComponent::Base
  attr_accessor :application_choice, :missing_uk_gcses

  def initialize(application_choice)
    @application_choice = application_choice
    @missing_uk_gcses = find_missing_uk_gcses(application_choice)
  end

  def provider_accepts_equivalencies?
    application_choice.course.accept_gcse_equivalency?
  end

private

  def no_qualifications_text
    subjects = missing_uk_gcses.map(&:subject)
    subjects[0] = subjects[0].capitalize if subjects[0] == 'english'
    subjects.to_sentence(last_word_connector: ' and ', two_words_connector: ' and ')
  end

  def course_accepted_equivalencies
    subjects = []
    subjects << 'English' if application_choice.course.accept_english_gcse_equivalency?
    subjects << 'maths' if application_choice.course.accept_maths_gcse_equivalency?
    subjects << 'science' if application_choice.course.accept_science_gcse_equivalency?

    subjects.to_sentence(last_word_connector: ' and ', two_words_connector: ' and ')
  end

  def find_missing_uk_gcses(application_choice)
    application_choice.application_form.application_qualifications
      .where(level: 'gcse', qualification_type: 'missing', other_uk_qualification_type: nil, institution_country: [nil, 'GB'], currently_completing_qualification: false)
      .sort_by(&:subject)
  end
end
