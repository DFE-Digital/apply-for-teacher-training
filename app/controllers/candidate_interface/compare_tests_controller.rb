module CandidateInterface
  class CompareTestsController < CandidateInterfaceController
    def index
      @tone_of_voice =  field_test(:tone_of_voice)
    end

    def new
      @tone_of_voice =  field_test(:tone_of_voice)
    end

    def create
      field_test_converted(:tone_of_voice)
      redirect_to candidate_interface_compare_tests_path
    end
  end
end
