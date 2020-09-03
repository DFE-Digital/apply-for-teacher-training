module UCAS
  def self.apply_url
    "https://#{RecruitmentCycle.current_year}.teachertraining.apply.ucas.com/apply/student/login.do"
  end
end
