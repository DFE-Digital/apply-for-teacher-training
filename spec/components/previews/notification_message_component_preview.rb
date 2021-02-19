class NotificationMessageComponentPreview < ViewComponent::Preview
  %i[warning info success].each do |state_name|
    define_method state_name do
      message = {
        message: Faker::Lorem.sentence,
        secondary_message: Faker::Lorem.sentence(word_count: 3),
        message_link: [{
          'text' => Faker::Lorem.sentence(word_count: 3),
          'url' => [Faker::Internet.url, nil].sample,
        }, nil].sample,
      }

      render NotificationMessageComponent.new(state_name, message)
    end
  end
end
