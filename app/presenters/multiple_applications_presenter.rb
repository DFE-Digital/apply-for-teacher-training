class MultipleApplicationsPresenter
  attr_reader :application_choices, :api

  def initialize(application_choices, api:)
    @application_choices = application_choices
    @api = api
  end

  def as_json
    application_choices.map do |application_choice|
      api::SingleApplicationPresenter.new(application_choice).as_json
    end
  end
end
