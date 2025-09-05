class CandidateInterface::PendingGcseRequiredComponent < ApplicationComponent
  attr_accessor :application_choice, :pending_uk_gcses

  def initialize(application_choice, pending_uk_gcses)
    @application_choice = application_choice
    @pending_uk_gcses = pending_uk_gcses
  end

  def pending_gcse_and_course_can_accept?
    @pending_uk_gcses.any? && !@application_choice.course.accept_pending_gcse?
  end

private

  def pending_gcse_text
    subjects = pending_uk_gcses.map(&:subject)
    subjects[0] = subjects[0].capitalize if subjects[0] == 'english'
    subjects.to_sentence(last_word_connector: ' and ', two_words_connector: ' and ')
  end
end
