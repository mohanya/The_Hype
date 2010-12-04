Then(/^I should see (\d+) #{capture_plural_factory}(?: within "([^"]*)")?$/) do |count, plural_factory, selector|
  class_name = plural_factory.singularize.underscore
  with_scope(selector) do
    elements = page.all(:css, ".#{class_name}")
    if page.respond_to? :should
      elements.count.should == count.to_i
    else
      assert_equal count.to_i, elements.count 
    end
  end 
end

Then /^(?:|I )should see "([^"]+)" element(?: within "([^"]*)")?$/ do |css, selector|
  with_scope(selector) do
    if page.respond_to? :should
      page.should have_css(css)
    else
      assert page.has_css?(css)
    end
  end
end

When(/^I follow "([^"]*)" within #{capture_model}'s partial$/) do |link, name|
  found_model = model(name) 
  partial_id = "#{found_model.class.to_s.underscore}_#{found_model.id}"
  steps %Q{
    When I follow "#{link}" within "##{partial_id}"
  }
end

Then(/^I should see #{capture_model}'s partial$/) do |name| #(?: within "([^"]*)")?$/) do |name, selector|
  found_model = model(name) 
  partial_id = "#{found_model.class.to_s.underscore}_#{found_model.id}"
  steps %Q{
    Then I should see "##{partial_id}" element
  }
end

Then(/^I should not see #{capture_model}'s partial(?: within "([^"]*)")?$/) do |name, selector|
  pending # find a way to cache captured model id
  found_model = model(name) 
  partial_id = "#{found_model.class.to_s.underscore}_#{found_model.id}"
  steps %Q{
    Then I should not see "##{partial_id}" within "#{selector}"
  }
end

