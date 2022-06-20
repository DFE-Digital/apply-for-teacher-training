namespace :api do
  task :check_applications, [:provider_id] => :environment do |_, args|
    Bullet.enable = true
    Bullet.bullet_logger = true

    provider = args[:provider_id].present? ? Provider.find(args[:provider_id]) : Provider.first
    ActiveRecord::Base.logger = Logger.new(STDOUT)

    puts Benchmark.measure {
      Bullet.profile {
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
              application_form: [
                :candidate,
                :english_proficiency,
                :application_references,
                :application_qualifications,
                :application_work_experiences,
                :application_volunteering_experiences,
                :application_work_history_breaks,
              ]
            ],
            providers: [provider]
          ).where('application_choices.updated_at > ?', since),
          ActionDispatch::Request.new({}),
          { since: since, page: 1, per_page: 50 }
        )
        presenter.serialized_applications_data
      }
    }

    # require 'ruby-prof'
    # RubyProf.start
    #  result = RubyProf.stop
    #  printer = RubyProf::FlatPrinter.new(result)
    #  printer.print(STDOUT)
  end
end
