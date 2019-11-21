module CandidateInterface
  class ChooseTrainingProviderForm
    include ActiveModel::Model

    attr_accessor :code

    validates :code, presence: true

    def is_another_provider_selected?
      code == 'other'
    end
  end
end
