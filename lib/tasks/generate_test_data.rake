task generate_test_data: :environment do
  GenerateTestData.new(100).generate
end
