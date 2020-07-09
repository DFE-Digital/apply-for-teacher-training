module CandidateInterface
  module EnglishForeignLanguage
    class IeltsForm
      include ActiveModel::Model

      attr_accessor :trf_number, :band_score, :award_year

      validates :trf_number, presence: true
      validates :band_score, presence: true
      validates :award_year, presence: true

      def save
        return false unless valid?

        true
      end
    end
  end
end
