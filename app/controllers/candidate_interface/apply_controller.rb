module CandidateInterface
  class ApplyController < CandidateInterfaceController
    def show
      @provider_code = params.fetch(:providerCode)
      @course_code = params.fetch(:courseCode)
    end
  end
end
