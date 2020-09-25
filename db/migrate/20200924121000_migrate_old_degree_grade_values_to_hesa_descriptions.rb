class MigrateOldDegreeGradeValuesToHesaDescriptions < ActiveRecord::Migration[6.0]
  def change
    first = ApplicationQualification.degrees.where(grade: %w[first First])
    first.update_all(grade: 'First class honours', grade_hesa_code: 1)

    upper_second = ApplicationQualification.degrees.where(grade: %w[upper_second 2:1])
    upper_second.update_all(grade: 'Upper second-class honours (2:1)', grade_hesa_code: 2)

    lower_second = ApplicationQualification.degrees.where(grade: %w[lower_second 2:2])
    lower_second.update_all(grade: 'Lower second-class honours (2:2)', grade_hesa_code: 3)

    third = ApplicationQualification.degrees.where(grade: %w[third Third])
    third.update_all(grade: 'Third-class honours', grade_hesa_code: 5)
  end
end
