desc 'Delete and create test data, including courses and options'
task generate_test_data: :environment do
  GenerateTestData.new(100).generate
end

desc 'Generate test applications for existing providers'
task generate_test_applications: :environment do
  GenerateTestApplications.new(for_year: :previous_year).perform

  GetApplicationChoicesReadyToRejectByDefault.call.find_each do |choice|
    rbd = choice.reject_by_default_at
    choice.update_columns(
      status: 'rejected',
      rejected_by_default: true,
      rejected_at: rbd,
      updated_at: rbd,
    )
    choice.application_form.update_columns(updated_at: rbd)
  end

  GenerateTestApplications.new(for_year: :current_year).perform
end

desc 'Generate a very large number of applications quickly, based on an example application form'
task :bulk_create_test_applications, %i[application_form_id number_of_applications] => :environment do |_t, args|
  template_application_form = ApplicationForm.find(args[:application_form_id])
  number_of_applications = args[:number_of_applications]
  raise 'Specify how many applications to create' unless number_of_applications

  bulk_creation = BulkCreateTestApplications.new(template_application_form)

  benchmark = Benchmark.measure do
    number_of_applications.to_i.times do
      bulk_creation.call
    end
  end

  puts benchmark
end
