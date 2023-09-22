module CandidateInterface
  class Section
    attr_accessor :controller, :condition

    def initialize(controller:, condition: nil)
      @controller = controller
      @condition = condition
    end

    def science_gcse?(policy)
      params = policy.params
      current_application = policy.current_application

      params[:subject] &&
        params[:subject] == 'science' &&
        current_application
          .application_choices
          .select(&:science_gcse_needed?)
          .all?(&:unsubmitted?)
    end
  end
end
