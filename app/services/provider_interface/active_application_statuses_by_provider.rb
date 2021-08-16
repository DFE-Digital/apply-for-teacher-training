module ProviderInterface
  class ActiveApplicationStatusesByProvider
    attr_reader :provider

    def initialize(provider)
      @provider = provider
    end

    def call
      grouped_course_data.map do |course_data|
        course = course_data.last
        {
          header: course.first.name_and_code.to_s,
          subheader: course.first.provider_name || provider.name,
          values: [course.find { |c| c.status == 'awaiting_provider_decision' }&.count || 0,
                   course.find { |c| c.status == 'interviewing' }&.count || 0,
                   course.find { |c| c.status == 'offer' }&.count || 0,
                   course.find { |c| c.status == 'pending_conditions' }&.count || 0,
                   course.find { |c| c.status == 'recruited' }&.count || 0],
        }
      end
    end

  private

    def grouped_course_data
      @course_data ||= GetApplicationProgressDataByCourse.new(provider: provider).call.group_by(&:id)
    end
  end
end
