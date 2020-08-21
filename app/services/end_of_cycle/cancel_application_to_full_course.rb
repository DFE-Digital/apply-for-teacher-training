module EndOfCycle
  class CancelApplicationToFullCourse
    def initialize(application_choice)
      @application_choice = application_choice
    end

    def call
      ApplicationStateChange.new(application_choice).cancel!
      CandidateMailer.send_eoc_email_explaining_that_course_choice_was_cancelled_because_its_full
    end
  end
end
