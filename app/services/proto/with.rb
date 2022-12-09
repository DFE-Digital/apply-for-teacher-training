class Proto::With
  def initialize(upstream:, count: nil, new_record: false)
    @upstream = upstream
    @count = count
    @new_record = new_record
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

  def same
    raise "Can't call `same` on `with`" unless new_record?

    Proto::UpstreamRecordFinder.new(upstream:)
  end

private

  attr_reader :count, :new_record

  def new_record?
    !!new_record
  end
end
