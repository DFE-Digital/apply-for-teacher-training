module CandidateInterface
  module Wizards
    class PersonalInformationWizard < DfE::Wizard
      include ::CandidateInterface::Wizards::PersonalInformationSteps
      attr_accessor :current_application

      steps do
        [
          { name_and_date_of_birth: NameAndDateOfBirthStep },
          { nationality: NationalityStep },
          { right_to_work_or_study: RightToWorkOrStudyStep },
          { visa_or_immigration_status: VisaOrImmigrationStatusStep },
        ]
      end

      store Stores::PersonalInformationStore

      def logger
        DfE::Wizard::Logger.new(Rails.logger, if: -> { HostingEnvironment.test_environment? })
      end
    end
  end
end
