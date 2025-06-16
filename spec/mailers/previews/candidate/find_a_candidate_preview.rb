class Candidate::FindACandidatePreview < ActionMailer::Preview
  def candidate_invites_multiple_providers
    candidate = FactoryBot.create(:candidate)
    FactoryBot.create(
      :application_form,
      :minimum_info,
      candidate: candidate,
      first_name: 'Fred',
    )

    provider = FactoryBot.create(:provider)
    course_1, course_2 = FactoryBot.create_list(:course,
                                                2,
                                                provider: provider,
                                                fee_domestic: 9535,
                                                fee_international: 15430)

    provider_1_invite_1 = FactoryBot.create(
      :pool_invite,
      candidate:,
      provider: provider,
      course: course_1,
      provider_message: true,
      message_content: "# Hello\r\n## Please apply to my course\r\n\r\n^ Some content\r\n\r\nByee",
    )

    provider_1_invite_2 = FactoryBot.create(
      :pool_invite,
      candidate:,
      provider: provider,
      course: course_2,
      provider_message: true,
      message_content: "# Hello\r\n## Please apply to my course\r\n\r\n^ Some content\r\n\r\nByee",
    )

    other_invites = FactoryBot.create_list(
      :pool_invite,
      2,
      candidate:,
    )

    pool_invites = [provider_1_invite_1, provider_1_invite_2] + other_invites

    CandidateMailer.candidate_invites(candidate, pool_invites)
  end

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

    CandidateMailer.candidate_invites(candidate, [invite])
  end

  def candidate_invites_one_provider_two_courses
    candidate = FactoryBot.create(:candidate)
    FactoryBot.create(
      :application_form,
      :minimum_info,
      candidate: candidate,
      first_name: 'Fred',
    )

    provider = FactoryBot.create(:provider)
    course_1, course_2 = FactoryBot.create_list(:course,
                                                2,
                                                provider: provider,
                                                fee_domestic: 9535,
                                                fee_international: 15430)

    invite_1 = FactoryBot.create(
      :pool_invite,
      candidate:,
      provider: provider,
      course: course_1,
      provider_message: true,
      message_content: "# Hello\r\n## Please apply to my course\r\n\r\n^ Some content\r\n\r\nByee",
    )

    invite_2 = FactoryBot.create(
      :pool_invite,
      candidate:,
      provider: provider,
      course: course_2,
      provider_message: true,
      message_content: "# Hello\r\n## Please apply to my course\r\n\r\n^ Some content\r\n\r\nByee",
    )

    CandidateMailer.candidate_invites(candidate, [invite_1, invite_2])
  end

  def candidate_invites_two_providers
    candidate = FactoryBot.create(:candidate)
    FactoryBot.create(
      :application_form,
      :minimum_info,
      candidate: candidate,
      first_name: 'Fred',
    )
    provider = FactoryBot.create(:provider)

    invite_1 = FactoryBot.create(
      :pool_invite,
      candidate:,
      provider: provider,
      provider_message: true,
      message_content: "# Hello\r\n## Please apply to my course\r\n\r\n^ Some content\r\n\r\nByee",
    )

    invite_2 = FactoryBot.create(
      :pool_invite,
      candidate:,
      provider: provider,
      provider_message: true,
      message_content: "# Hello\r\n## Please apply to my course\r\n\r\n^ Some content\r\n\r\nByee",
    )

    CandidateMailer.candidate_invites(candidate, [invite_1, invite_2])
  end
end
