module MoreApplicationData
  extend ActiveSupport::Concern
  VERSION = '1.2'

  def schema
    return super unless version >= VERSION

    super.merge!({
      recruitment_cycle_year: recruitment_year
    })
  end

  def recruitment_year
    application_choice.course.recruitment_cycle_year
  end
end
