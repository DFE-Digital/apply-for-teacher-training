desc 'Generate test applications for existing providers'
task generate_test_applications: :environment do
  GenerateTestApplications.new.perform
end

desc 'Generate a very large number of applications quickly, based on an example application form'
task :bulk_create_test_applications, %i[application_form_id number_of_applications] => :environment do |_t, args|
  raise 'Not permitted on this environment' unless HostingEnvironment.generate_test_data?

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
