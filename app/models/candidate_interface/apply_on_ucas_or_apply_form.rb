module CandidateInterface
  class ApplyOnUCASOrApplyForm
    include ActiveModel::Model

    attr_accessor :service, :provider_code, :course_code

    validates :service, presence: true

    def apply?
      service == 'apply'
    end
  end
end
