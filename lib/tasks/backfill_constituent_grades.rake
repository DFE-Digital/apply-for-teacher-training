desc 'Transforms structured qualifications to use constituent_grades column rather than structured_grades'
task backfill_constituent_grades: :environment do
  structured_qualifications = ApplicationQualification.where(constituent_grades: nil).where.not(structured_grades: nil)

  structured_qualifications.each do |qualification|
    grades = JSON.parse(qualification.structured_grades)

    constituent_grades = grades.transform_values { |grade| { grade: grade } }.to_json

    qualification.update(constituent_grades: constituent_grades)
  end
end
