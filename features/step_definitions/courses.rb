Given("the following providers:") do |table|
  table.hashes.each do |row|
    Provider.create!(
      code: row['provider code'],
      accredited_body: row['is an accredited body?'] == 'Y'
    )
  end
end

Given("the following courses:") do |table|
  table.hashes.each do |row|
    Course.create!(
      course_code: row['course code'],
      provider: Provider.find_by!(code: row['provider code']),
      accredited_body_code: row['accredited body']
    )
  end
end

When(/an application has been made to a course (.*)/) do |course_code|
  course = Course.find_by(course_code: course_code)

  @application = CandidateApplication.create(course: course)
end

Then(/(.*) and (.*) are treated as the same choice: (.*)/) do |course_a, course_b, yes_or_no|
  pending
end
