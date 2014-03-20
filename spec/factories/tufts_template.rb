FactoryGirl.define do
  factory :tufts_template do
    sequence(:template_name) {|n| "Template #{n}" }
    title "updated title"
  end
end
