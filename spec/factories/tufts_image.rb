FactoryGirl.define do
  factory :tufts_image, aliases: [:image] do
    displays { ['dl'] }
    sequence(:title) {|n| "Title #{n}" }
  end
end
