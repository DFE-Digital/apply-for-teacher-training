module CandidateInterface
  class ImmigrationRouteForm
    include ActiveModel::Model

    attr_accessor :immigration_route, :immigration_route_details

    validates :immigration_route, presence: true
    validates :immigration_route_details, presence: true, if: :other_immigration_route?

    def self.build_from_application(application_form)
      new(
        immigration_route: application_form.immigration_route,
        immigration_route_details: application_form.immigration_route_details,
      )
    end

    def save(application_form)
      return false unless valid?

      application_form.update(
        immigration_route: immigration_route,
        immigration_route_details: other_immigration_route? ? immigration_route_details : nil,
        immigration_status: nil,
        immigration_status_details: nil,
        immigration_entry_date: nil,
      )
    end

  private

    def other_immigration_route?
      immigration_route == 'other_route'
    end
  end
end
