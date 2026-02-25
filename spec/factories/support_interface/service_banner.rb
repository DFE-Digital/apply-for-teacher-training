FactoryBot.define do
  factory :service_banner do
    header     { 'The service will be unavailable this evening between 6pm and 9pm' }
    body       { 'You may lose work if you do not save it before 6pm' }
    interface  { 'apply' }
    status     { :draft }

    trait :published do
      status { :published }
    end

    trait :used do
      status { :used }
    end

    trait :audited do
      status { :published }
    end

    trait :manage do
      body { 'You may lose data if you are processing applications at this time' }
      interface { 'manage' }
    end

    trait :support_console do
      header { 'The service will be unavailable this evening between 6pm and 9pm' }
      body { 'Candidates and providers have been made aware' }
      interface { 'support_console' }
    end
  end
end
