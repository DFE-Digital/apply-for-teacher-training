require 'sidekiq/testing'

desc 'Delete and create test data, including courses and options'
task generate_test_data: :environment do
  GenerateTestData.new(100).generate
end

desc 'Generate test applications for existing providers'
task generate_test_applications: :environment do
  Sidekiq::Testing.inline! do
    GenerateTestApplications.new.perform
  end
end
