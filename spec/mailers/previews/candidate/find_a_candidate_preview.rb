class Candidate::FindACandidatePreview < ActionMailer::Preview
  def candidate_invites_one_provider
    candidate = FactoryBot.create(:candidate)
    FactoryBot.create(
      :application_form,
      :minimum_info,
      candidate: candidate,
      first_name: 'Fred',
    )

    provider = FactoryBot.create(:provider)
    course = FactoryBot.create(:course,
                               provider: provider,
                               fee_domestic: 9535,
                               fee_international: 15430)

    invite = FactoryBot.create(
      :pool_invite,
      candidate:,
      provider: provider,
      course: course,
      provider_message: true,
      message_content: "# Hello\r\n## Please apply to my course\r\n\r\n^ Some content\r\n\r\nByee",
    )

    CandidateMailer.candidate_invite(candidate, invite)
  end
end
