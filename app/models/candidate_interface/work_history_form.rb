module CandidateInterface
  class WorkHistoryForm
    include ActiveModel::Model

    attr_accessor :work_history

    validates :work_history, presence: true
  end
end
