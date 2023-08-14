module CandidateInterface
  module ContinuousApplications
    class SubmitApplicationForm
      include ActiveModel::Model
      attr_accessor :application_choice, :submit_answer

      validates :submit_answer, presence: true

      Option = Struct.new(:answer, :name, :description, keyword_init: true)

      def submit_now?
        submit_answer == 'yes'
      end

      def options
        [
          Option.new(answer: 'yes', name: 'Yes, submit it now', description: 'By submitting this application, you confirm that your details are true, complete and accurate.'),
          Option.new(answer: 'no', name: 'No, save it as a draft'),
        ]
      end
    end
  end
end
