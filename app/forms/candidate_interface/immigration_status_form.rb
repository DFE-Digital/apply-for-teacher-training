module CandidateInterface
  class ImmigrationStatusForm
    include ActiveModel::Model

    attr_accessor :immigration_route

    validates :immigration_status, presence: true

    def self.build_from_application(application_form)
      new(
        immigration_status: application_form.immigration_status,
      )
    end

    def save(application_form)
      return false unless valid?

      application_form.update(
        immigration_status: immigration_status,
      )
    end
  end
end
