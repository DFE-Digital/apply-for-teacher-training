# frozen_string_literal: true

class CandidateInterface::ChoicesControllerMatcher
  APPLICATION_CHOICE_CONTROLLER_PATHS = [
    'candidate_interface/course_choices', # the course choice wizard
    'candidate_interface/application_choices', # controller for Your applications & deleting an application choice
    'candidate_interface/decisions', # withdrawing from a course offer, the old way
    'candidate_interface/withdrawal_reasons', # Withdrawing the new way
    'candidate_interface/apply_from_find',
    'candidate_interface/share_details',
    'candidate_interface/pool_opt_ins',
    'candidate_interface/draft_preferences',
    'candidate_interface/dynamic_location_preferences',
    'candidate_interface/training_locations',
    'candidate_interface/location_preferences',
    'candidate_interface/publish_preferences',
    'candidate_interface/course_type',
  ].freeze

  def self.choices_controller?(current_application:, controller_path:, request:)
    return false if current_application.v23?

    choices_controllers = Regexp.compile(APPLICATION_CHOICE_CONTROLLER_PATHS.join('|'))

    controller_path.match?(choices_controllers) ||
      (controller_path.match?('candidate_interface/guidance') && request.referer&.match?('choices'))
  end
end
