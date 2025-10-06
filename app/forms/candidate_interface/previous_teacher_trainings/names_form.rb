module CandidateInterface
  module PreviousTeacherTrainings
    class NamesForm
      include ActiveModel::Model

      attr_accessor :provider_name, :previous_teacher_training

      validates :provider_name, presence: true, length: { maximum: 100 }

      def initialize(previous_teacher_training)
        @previous_teacher_training = previous_teacher_training
        @provider_name = previous_teacher_training.provider_name
      end

      def providers
        @providers ||= GetAvailableProviders.call
      end

      def save
        return if invalid?

        previous_teacher_training.provider_name = provider_name
        previous_teacher_training.provider_id = Provider.find_by(name: provider_name)&.id
        previous_teacher_training.save!
      end
    end
  end
end
