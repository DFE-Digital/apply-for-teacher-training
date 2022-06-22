class MeasureSerializingApplications
  attr_accessor :args, :provider, :page, :per_page, :full_api_version_number

  def initialize(args)
    @args = args
    @provider = args[:provider_id].present? ? Provider.find(args[:provider_id]) : Provider.first
    @page = 1
    @per_page = 50
    @full_api_version_number = '1.1'

    send :extend, VendorAPI::ApplicationDataConcerns
  end

  delegate :call, to: :measure_block

  def measure_block
    lambda {
      since = Time.zone.iso8601('0001-01-01T01:00:00')
      applications = application_choices_visible_to_provider
        .where('application_choices.updated_at > ?', since)
      presenter = VendorAPI::MultipleApplicationsPresenter.new(
        '1.1',
        applications,
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

    puts
    puts 'Save profiling results to:'
    puts "* #{flat_printer_filename}"
    puts "* #{graph_filename}"
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

  def current_provider
    @provider
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
      bullet_file = 'log/bullet.log'
      File.truncate(bullet_file, 0)
      MeasureSerializingApplications.new(args).shoot
      puts '=' * 80
      puts 'Bullet results'
      puts '=' * 80
      puts File.read(bullet_file)
      puts '=' * 80
    end
  end
end
