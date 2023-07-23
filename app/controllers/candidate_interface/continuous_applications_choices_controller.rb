module CandidateInterface
  class ContinuousApplicationsChoicesController < ContinuousApplicationsController
    def index
      @application_form_presenter = CandidateInterface::ApplicationFormPresenter.new(current_application)
    end
  end
end
# class ContinuousApplicationsCourseSelectionController < ContinuousApplicationsController
#   def show
#     @course_selection_wizard = CourseSelectionWizard.new(
#       current_step:,
#       params:,
#       request:,
#     )
#   end
#
#   def update
#     @course_selection_wizard = CourseSelectionWizard.new_answer(
#       current_step:,
#       params:,
#       request:,
#     )
#   end
# end
#
# class CourseSelectionWizard < DfE::Wizard
#  # data_store :name, service: SomeService
#  # This Service class will receive the calls from the wizard #save #find
#  # destroy
#  #
#  # options could be
#  # :session
#  # :active_record
#  # :params
#  # #save and #delete from Redis (specify a key name with "key_name" method)
#  # data_store :redis, service: SaveCourseService
#  #
#  # Default to save from all steps
#  # data_store :active_record, service: SaveCourseService
#
#  steps do
#    [
#      { do_you_know_the_course: CourseSelection::DoYouKnowTheCourseForm },
#      { go_to_find: :none },
#      { provider_selection: CourseSelection::ProviderSelectionForm },
#      { you_already_have_draft: CourseSelection::YouAlreadyHaveDraftForm },
#      { course: CourseSelection::CourseForm },
#      { study_mode: CourseSelection::StudyModeForm },
#    ]
#  end
#
#  # You can overwrite this methods
#  def previous_step_path
#  end
#
#  # You can overwrite this methods
#  def next_step_path
#  end
# end
#
# class CourseSelection::DoYouKnowTheCourseForm < DfE::WizardStep
#  def self.permitted_params
#  end
#
#  def fields
#   [
#     Fields::FieldType.new(
#       :radio_option,
#       []  # options
#     )
#   ]
#  end
#
#  def previous_step
#    # wizard is an instance
#  end
#
#  def next_step
#  end
# end
#
# Also create a rails task to generate all graphs
#
#  rails dfe:wizards:graphs
#
#  DfE::Wizard.subclasses.each { |wizard_class| DfE::WizardGraphGenerator.new(wizard_class) }
#
