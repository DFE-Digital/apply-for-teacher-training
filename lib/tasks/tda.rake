desc 'Convert all courses from current cycle to TDA'
task convert_tda_courses: :environment do
  ActiveRecord::Base.transaction do
    Course.current_cycle.find_each do |course|
      course.qualifications = ['qts', 'tda']
      course.funding_type = 'apprenticeship'
      course.description = 'Teacher degree apprenticeship with QTS full time teaching apprenticeship'
      course.save
    end
  end
end
