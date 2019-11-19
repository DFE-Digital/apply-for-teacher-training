class RefereesReviewComponent < ActionView::Component::Base
  validates :application_form, presence: true

  def initialize(application_form:, editable: true, deletable: true)
    @application_form = application_form
    @editable = editable
    @deletable = deletable
  end

  def referee_rows(work)
    [
      name_row(work),
      email_row(work),
      relationship_row(work),
    ]
      .compact
  end

private

  attr_reader :application_form

  def name_row(referee)
    {
      key: 'Name',
      value: referee.name,
      action: ('job' if @editable),
      change_path: (candidate_interface_edit_referee_path(referee.id) if @editable),
    }
  end

  def email_row(referee)
    {
      key: 'Email address',
      value: referee.email_address,
      action: ('email_address' if @editable),
      change_path: (candidate_interface_edit_referee_path(referee.id) if @editable),
    }
  end

  def relationship_row(referee)
    {
      key: 'Relationship',
      value: referee.relationship,
      action: ('relationship' if @editable),
      change_path: (candidate_interface_edit_referee_path(referee.id) if @editable),
    }
  end
end
