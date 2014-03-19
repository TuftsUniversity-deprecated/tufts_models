FactoryGirl.define do
  factory :tufts_template do
    sequence(:template_title) {|n| "Title #{n}" }
    title "updated title"
  end
end
