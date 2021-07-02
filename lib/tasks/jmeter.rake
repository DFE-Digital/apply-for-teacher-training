# Guidance for this task can be found at docs/load_testing.md

desc 'Generates jmeter test plan'
task :generate_jmeter_plan, [:host, :thread_count, :token] do |_t, args|
  require 'ruby-jmeter'
  generate_plan extract_options_from(args)
end

def extract_options_from(args)
  defaults = {
    host: 'http://localhost:3000',
    thread_count: 10,
    token: nil,
  }

  options = defaults.merge(args)
  options[:thread_count] = options[:thread_count].to_i

  raise ArgumentError, 'Missing token!' if options[:token].nil?

  puts("Generating jmeter plan with the following options:\n
         host: #{options[:host]}\n
         thread_count: #{options[:thread_count]}\n
         token: #{options[:token]}\n")

  options
end

def generate_plan(host:, thread_count:, token:)
  test do
    threads count: thread_count do
      visit name: 'GET candidate landing page', url: "#{host}/candidate" do
        assert contains: 'Apply for teacher training'
      end

      visit name: 'GET candidate account page', url: "#{host}/candidate/account" do
        assert contains: 'Create an account or sign in'
      end

      header name: 'COOKIE', value: "_apply_for_postgraduate_teacher_training_session=#{token}"

      visit name: 'GET application', url: "#{host}/candidate/application" do
        assert contains: 'Your application'
      end

      visit name: 'GET contact-details', url: "#{host}/candidate/application/contact-details" do
        assert contains: 'Contact details'
        extract name: 'csrf-token', xpath: "//meta[@name='csrf-token']/@content", tolerant: true
      end

      header name: 'X-CSRF-Token', value: '${csrf-token}'

      submit name: 'POST contact-details',
             url: "#{host}/candidate/application/contact-details",
             fill_in: {
               'candidate_interface_contact_details_form[phone_number]' => '07173 473748',
             }
    end
    view_results_in_table
    view_results_tree
    graph_results
    aggregate_graph
  end.jmx
end
