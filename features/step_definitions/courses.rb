Given('the following providers:') do |table|
  table.hashes.each do |row|
    provider = Provider.create!(
      code: row['provider code'],
      accredited_body: row['is an accredited body?'] == 'Y'
    )

    if row['provider training locations']
      training_location_codes = row['provider training locations'].split(', ')
      training_location_codes.each do |code|
        TrainingLocation.create!(
          code: code,
          provider: provider
        )
      end
    end
  end
end

Given('the following courses:') do |table|
  table.hashes.each do |row|
    course = Course.create!(
      course_code: row['course code'],
      provider: Provider.find_by!(code: row['provider code']),
      accredited_body: Provider.find_by!(code: row['accredited body'] || row['provider code']) # self-accredited if not specified
    )

    if row['course training locations']
      course_training_location_codes = row['course training locations'].split(', ')
      course_training_location_codes.each do |training_location_code|
        course.training_locations << course.provider.training_locations.find_by!(code: training_location_code)
      end
    end
  end
end

When(/an application has been made to course (.*)\/(.*)/) do |provider_code, course_code|
  course = Provider
             .find_by!(code: provider_code)
             .courses
             .find_by!(course_code: course_code)

  @application = CandidateApplication.create!(course: course)
end

Then(/(.*) and (.*) are treated as the same choice: (.*)/) do |_course_a, _course_b, _yes_or_no|
  pending
end
