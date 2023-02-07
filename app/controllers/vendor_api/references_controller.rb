module VendorAPI
  class ReferencesController < VendorAPIController
    before_action :workflow_testing_only

    def success
      with_requested_reference do |reference|
        reference.update!(
          feedback_status: 'feedback_provided',
          feedback_provided_at: Time.zone.now,
          feedback: Faker::Lorem.paragraph(sentence_count: 10),
          safeguarding_concerns: '',
          relationship_correction: '',
        )
      end
    end

    def failure
      with_requested_reference do |reference|
        reference.update!(
          feedback_status: 'feedback_refused',
          feedback_refused_at: Time.zone.now,
        )
      end
    end

  private

    def workflow_testing_only
      render json: nil, status: :not_found unless HostingEnvironment.workflow_testing?
    end

    def with_requested_reference
      reference = current_provider.application_references.find(params[:id])

      if reference.feedback_status == 'feedback_requested'
        yield reference

        render json: nil, status: :ok
      else
        render json: nil, status: :unprocessable_entity
      end
    end
  end
end
