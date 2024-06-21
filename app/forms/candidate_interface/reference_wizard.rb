module CandidateInterface
  class ReferenceWizard < DfE::Wizard::Base
    attr_accessor :reference_process, :current_application, :application_choice,
      :reference, :return_to_path

    steps do
      [
        { reference_type: References::TypeStep },
        { reference_name: References::NameStep },
        { reference_email_address: References::EmailAddressStep },
        { reference_relationship: References::RelationshipStep },
      ]
    end

    store ReferenceStore

    #attr_accessor :current_application, :application_choice

    #steps do
    #  [
    #    { do_you_know_the_course: DoYouKnowTheCourseStep },
    #  ]
    #end

    #store CourseSelectionStore

    #def logger
    #  DfE::Wizard::Logger.new(Rails.logger, if: -> { HostingEnvironment.test_environment? })
    #end

    #def completed?
    #  current_step.respond_to?(:completed?) && current_step.completed?
    #end
  end
end
