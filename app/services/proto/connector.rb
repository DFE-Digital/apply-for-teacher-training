class Proto::Connector
  def initialize(upstream:, count: nil)
    @upstream = upstream
    @count = count
  end

  attr_accessor :upstream

  def application_form
    upstream.application_form(new_record:)
  end

  def submitted_application
    upstream.submitted_application(new_record:)
  end

  def rejected_application
    upstream.rejected_application(new_record:)
  end

  def application_choice
    upstream.application_choice(new_record:)
  end

  def application_choices
    upstream.application_choices(count:, new_record:)
  end

  delegate :course_option, to: :upstream

private

  attr_reader :count, :new_record
end
