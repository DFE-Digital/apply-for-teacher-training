module CandidateInterface
  class ImmigrationStatus
    delegate :immigration_status, :right_to_work_or_study, to: :current_application

    attr_reader :current_application

    def initialize(current_application:)
      @current_application = current_application
    end

    def incomplete?
      right_to_work_or_study? && !british_or_irish? && immigration_status.blank?
    end

    def british_or_irish?
      UK_AND_IRISH_NATIONALITIES.intersect?(current_application.nationalities)
    end

    def right_to_work_or_study?
      right_to_work_or_study == 'yes'
    end
  end
end
