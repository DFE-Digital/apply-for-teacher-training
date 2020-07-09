module CandidateInterface
  module EnglishForeignLanguage
    class StartForm
      include ActiveModel::Model

      attr_accessor :efl_qualification

      validates :efl_qualification, presence: true

      def save
        return false unless valid?

        true
      end
    end
  end
end
