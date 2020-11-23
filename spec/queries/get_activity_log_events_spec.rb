require 'rails_helper'

RSpec.describe GetActivityLogEvents, with_audited: true do
  around do |example|
    @now = Time.zone.local(2020, 2, 11)
    Timecop.travel(@now) { example.run }
  end

  let(:provider_user) { create(:provider_user, :with_two_providers) }
  let(:application_choices_for_provider_user) { GetApplicationChoicesForProviders.call(providers: provider_user.providers) }
  let(:service) { GetActivityLogEvents.new(application_choices: application_choices_for_provider_user) }

  let(:course_provider_a) { create(:course, provider: provider_user.providers.first) }
  let(:course_provider_b) { create(:course, provider: provider_user.providers.second) }
  let(:course_unrelated) { create(:course) }
  let(:ratified_course_provider_b) { create(:course, accredited_provider: provider_user.providers.second) }
  let(:ratified_course_unrelated) { create(:course, accredited_provider: create(:provider)) }

  def create_application_choice_for_course(course)
    course_option = course.course_options.first
    course_option ||= create(:course_option, course: course)
    create(:application_choice, :awaiting_provider_decision, course_option: course_option)
  end

  def create_audit_for_application_choice(application_choice, changes: {})
    create(:application_choice_audit, user: provider_user, application_choice: application_choice, changes: changes)
  end

  describe '#call' do
    it 'raises an error unless application_choices responds_to #to_sql ' do
      array = 2.times.map { create_application_choice_for_course(course_provider_a) }
      expect { GetActivityLogEvents.new(application_choices: array).call }.to raise_error(NoMethodError)
    end

    it 'returns an empty array if no audits are found' do
      expect(service.call).to eq([])
    end

    it 'returns objects responding to the required attributes' do
      choice = create_application_choice_for_course course_provider_a
      create_audit_for_application_choice choice

      result = service.call

      expect(result.count).to eq(1)

      %i[created_at auditable].each do |attr|
        expect(result.first).to respond_to(attr)
      end
    end

    it 'supports an since: argument for limiting number of events' do
      choice = create_application_choice_for_course course_provider_a
      create_audit_for_application_choice choice

      expected = create(
        :application_choice_audit,
        user: provider_user,
        application_choice: choice,
        created_at: @now + 1.day,
      )

      result = service.call(since: @now + 6.hours)

      expect(result.first).to eq(expected)
    end
  end

  context 'includes all and only relevant audits' do
    it 'filters on action == update' do
      choice = create_application_choice_for_course course_provider_a

      result = service.call

      expect(choice.audits.count).to eq(1)
      expect(choice.audits.first.action).to eq('create')
      expect(result.count).to eq(0)
    end
  end

  context 'sorts events in reverse chronological order' do
    it 'within an application' do
      choice = create_application_choice_for_course course_provider_a
      audits = 3.times.map { create_audit_for_application_choice choice }

      result = service.call

      expect(result.map(&:id)).to eq(audits.reverse.map(&:id))
    end

    it 'across applications and providers' do
      choice_a = create_application_choice_for_course course_provider_a
      choice_b = create_application_choice_for_course course_provider_b

      audits = 5.times.map do
        create_audit_for_application_choice [choice_a, choice_b].sample
      end

      result = service.call

      expect(result.map(&:id)).to eq(audits.reverse.map(&:id))
    end
  end

  context 'completes in a reasonable timeframe' do
    it '<50ms for 1000 application choices' do
      skip 'This spec takes a long time and should be run manually'

      1000.times do
        %i[course_provider_a course_provider_b course_unrelated ratified_course_provider_b ratified_course_unrelated].each do |course|
          choice = create_application_choice_for_course send(course)
          20.times.map { create_audit_for_application_choice choice }
        end
      end

      elapsed_time = Benchmark.measure { service.call }.real
      puts "GetProviderActivityLogEvents #call completed in #{elapsed_time}s"

      expect(elapsed_time).to be < 0.05
    end
  end
end
