module MoreApplicationData
  extend ActiveSupport::Concern

  def schema
    super.merge!({
      recruitment_cycle_year: recruitment_year
    })
  end

  def recruitment_year
    application_choice.course.recruitment_cycle_year
  end
end
