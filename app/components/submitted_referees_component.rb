class SubmittedRefereesComponent < ActionView::Component::Base
  validates :application_form, presence: true

  def initialize(application_form:)
    @application_form = application_form
  end

  def referee_rows(work)
    [
      name_row(work),
      email_row(work),
      relationship_row(work),
    ]
  end

private

  attr_reader :application_form

  def name_row(referee)
    {
      key: 'Name',
      value: referee.name,
    }
  end

  def email_row(referee)
    {
      key: 'Email address',
      value: referee.email_address,
    }
  end

  def relationship_row(referee)
    {
      key: 'Relationship',
      value: referee.relationship,
    }
  end
end
