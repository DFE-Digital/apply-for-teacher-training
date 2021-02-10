desc 'Transforms structured qualifications to use constituent_grades column rather than structured_grades'
task backfill_constituent_grades: :environment do
  structured_qualifications = ApplicationQualification.where(constituent_grades: nil).where.not(structured_grades: nil)

  structured_qualifications.each do |qualification|
    grades = get_structured_grades_hash(qualification)

    constituent_grades = grades.transform_values { |grade| { grade: grade } }

    qualification.update(constituent_grades: constituent_grades)
  end
end

def get_structured_grades_hash(qualification)
  if qualification.structured_grades.is_a?(Hash)
    qualification.structured_grades
  else
    JSON.parse(qualification.structured_grades)
  end
end
