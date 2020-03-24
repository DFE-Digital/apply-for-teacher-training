module CandidateInterface
  class ApplyOnUcasOrApplyForm
    include ActiveModel::Model

    attr_accessor :service, :provider_code, :course_code

    validates :service, presence: true

    def ucas?
      service == 'ucas'
    end
  end
end
