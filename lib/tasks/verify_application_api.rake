class MeasureSerializingApplications
  attr_accessor :args, :provider, :page, :per_page

  def initialize(args)
    @args = args
    @provider = args[:provider_id].present? ? Provider.find(args[:provider_id]) : Provider.first
    @page = 1
    @per_page = 50
  end

  delegate :call, to: :measure_block

  def measure_block
    lambda {
      since = Time.zone.iso8601('0001-01-01T01:00:00')
      presenter = VendorAPI::MultipleApplicationsPresenter.new(
        '1.1',
        GetApplicationChoicesForProviders.call(
          includes: [
            :course,
            :provider,
            offer: [:conditions],
            notes: [:user],
            interviews: [:provider],
            current_course_option: [:site, { course: [:provider] }],
            course_option: [:site, { course: [:provider] }],
            application_form: %i[
              candidate
              english_proficiency
              application_references
              application_qualifications
              application_work_experiences
              application_volunteering_experiences
              application_work_history_breaks
            ],
          ],
          providers: [provider],
        ).where('application_choices.updated_at > ?', since),
        ActionDispatch::Request.new({}),
        { since: since, page: page, per_page: per_page },
      )
      presenter.serialized_applications_data
    }
  end

  def benchmark
    result = Benchmark.measure(&measure_block)
    puts
    puts '=' * 80
    puts result
    puts '=' * 80
    puts
  end

  def profiling
    require 'ruby-prof'
    RubyProf.start
    measure_block.call
    result = RubyProf.stop

    flat_printer_filename = Rails.root.join('tmp/flat-printer.txt').to_s
    File.open flat_printer_filename, 'w' do |file|
      RubyProf::FlatPrinter.new(result).print(file)
    end

    graph_filename = Rails.root.join('tmp/profile-graph.html').to_s
    File.open graph_filename, 'w' do |file|
      RubyProf::GraphHtmlPrinter.new(result).print(file)
    end

    tree_filename = Rails.root.join('tmp/tree-graph.prof').to_s
    File.open tree_filename, 'w' do |file|
      RubyProf::CallTreePrinter.new(result).print(file)
    end

    puts
    puts 'Save profiling results to:'
    puts "* #{flat_printer_filename}"
    puts "* #{graph_filename}"
    puts "* #{tree_filename}"
    puts
  rescue LoadError
    puts 'Add ruby-prof to Gemfile to run this task.'
    puts 'gem "ruby-prof"'
  end

  def shoot
    Bullet.enable = true
    Bullet.bullet_logger = true

    Bullet.profile do
      measure_block.call
    end
  end
end

namespace :api do
  namespace :applications do
    desc 'Benchmark serializing applications from the Vendor API'
    task :benchmark, [:provider_id] => :environment do |_, args|
      MeasureSerializingApplications.new(args).benchmark
    end

    desc 'Profile serializing applications from the Vendor API'
    task :profile, [:provider_id] => :environment do |_, args|
      MeasureSerializingApplications.new(args).profiling
    end

    desc 'Identifying N+1 queries when serializing data from the Vendor API'
    task :bullet, [:provider_id] => :environment do |_, args|
      sh('truncate -s 0 log/bullet.log') # Empty the file for a fresh start
      MeasureSerializingApplications.new(args).shoot
      sh('cat log/bullet.log')
    end
  end
end
