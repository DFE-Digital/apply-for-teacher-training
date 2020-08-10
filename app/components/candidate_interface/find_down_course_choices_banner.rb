module CandidateInterface
  class FindDownCourseChoicesBanner < ViewComponent::Base
    validates :application_form, presence: true

    def initialize(find_down: false)
      @find_down = find_down
    end
  end
end
