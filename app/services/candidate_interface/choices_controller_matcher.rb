# frozen_string_literal: true

class CandidateInterface::ChoicesControllerMatcher
  APPLICATION_CHOICE_CONTROLLER_PATHS = [
    'continuous_applications_choices', # controller for Your applications
    'continuous_applications/course_choices', # the course choice wizard
    'continuous_applications/application_choices', # deleting an application choice
    'decisions', # withdrawing from a course offer
    'candidate_interface/apply_from_find',
  ].freeze

  def self.choices_controller?(current_application:, controller_path:, request:)
    return false if current_application.v23?

    choices_controllers = Regexp.compile(APPLICATION_CHOICE_CONTROLLER_PATHS.join('|'))

    controller_path.match?(choices_controllers) ||
      (controller_path.match?('candidate_interface/guidance') && request.referer&.match?('choices'))
  end
end
