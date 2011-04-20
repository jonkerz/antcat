
Given /the following references? exists?/ do |table|
  Reference.delete_all
  table.hashes.each do |hash|
    citation = hash.delete 'citation'
    matches = citation.match /(\w+) (\d+):([\d\-]+)/
    hash.merge! :journal => Factory(:journal, :name => matches[1]), :series_volume_issue => matches[2],
      :pagination => matches[3]
    create_reference :article_reference, hash
  end
end

Given /the following book references? exists?/ do |table|
  table.hashes.each do |hash|
    citation = hash.delete 'citation'
    matches = citation.match /([^:]+): (\w+), (.*)/
    hash.merge! :publisher => Factory(:publisher, :name => matches[2],
                                      :place => Factory(:place, :name => matches[1])),
                :pagination => matches[3]
    create_reference :book_reference, hash
  end
end

Given /the following unknown references? exists?/ do |table|
  table.hashes.each do |hash|
    create_reference :unknown_reference, hash
  end
end

Given /an author name exists with a name of "(.*?)"/ do |name|
  Factory :author_name, :name => name
end

def create_reference type, hash
  author = hash.delete('author') || hash.delete('authors')
  hash[:citation_year] = hash.delete 'year'
  reference = Factory type, hash.merge(:author_names => [Factory :author_name, :name => author])
  @reference ||= reference
  set_timestamps reference, hash
  Reference.reindex
end

def set_timestamps reference, hash
  Reference.connection.execute("UPDATE `references` SET updated_at = '#{hash[:updated_at]}' WHERE id = #{reference.id}") if hash[:updated_at]
  Reference.connection.execute("UPDATE `references` SET created_at = '#{hash[:created_at]}' WHERE id = #{reference.id}") if hash[:created_at]
end

Given /the following are duplicates/ do |table|
  target = Reference.find_by_year table.hashes.first[:year]
  duplicate = Reference.find_by_year table.hashes.second[:year]
  DuplicateReference.create! :reference => target, :duplicate => duplicate, :similarity => table.hashes.second[:similarity]
end

Given 'the following species exist' do |table|
  table.hashes.each do |hash|
    Factory :species, hash
  end
end

Given /the following entry nests it/ do |table|
  data = table.hashes.first
  @nestee_reference = @reference
  @reference = NestedReference.create! :author_names => [Factory(:author_name, :name => data[:authors])],
    :citation_year => data[:year], :title => data[:title], :pages_in => data[:pages_in],
    :nested_reference => @nestee_reference
  Reference.reindex
end

Given /that the entry has a URL that's on our site( that is public)?/ do |is_public|
  @reference.update_attribute :document, ReferenceDocument.create!
  @reference.document.update_attributes :url => "localhost/documents/#{@reference.document.id}/123.pdf",
                                        :file_file_name => '123.pdf',
                                        :public => is_public ? true : nil
end

Given /that the entry has a URL that's not on our site/ do
  @reference.update_attribute :document, ReferenceDocument.create!
  @reference.document.update_attribute :url,  'google.com/foo'
end

Given /the following user exists/ do |table|
  table.hashes.each {|hash| User.create! hash}
end

Then /I should see these entries (with a header )?in this order:/ do |with_header, entries|
  offset = with_header ? 2 : 1
  entries.hashes.each_with_index do |e, i|
    page.should have_css "table.references tr:nth-of-type(#{i + offset}) td", :text => e['entry']
    page.should have_css "table.references tr:nth-of-type(#{i + offset}) td", :text => e['date']
  end
end

Then /I should see "([^"]*)" in italics/ do |italicized_text|
  page.should have_css('span.genus_or_species', :text => italicized_text)  
end

Then /^there should be the HTML "(.*)"$/ do |html|
  body.should =~ /#{html}/
end

Then /I should (not )?see the edit form/ do |should_not|
  selector = should_not ? :should_not : :should
  css_selector = "#reference_"
  css_selector << @reference.id.to_s if @reference
  find("#{css_selector} .reference_edit").send(selector, be_visible)
end

Then /there should not be an edit form/ do
  page.should have_no_css "#reference_#{@reference.id} .reference_edit"
end

Then /I should (not )?see (?:a|the) new edit form/ do |should_not|
  selector = should_not ? :should_not : :should
  find("#reference_ .reference_edit").send(selector, be_visible)
end

Then 'I should not see the reference' do
  find("#reference_#{@reference.id} .reference_display").should_not be_visible
end

Then /the "(.+)" link should (not )?be visible/ do |text, should_not|
  find_link(text).visible?.should == !should_not
end

Then 'there should be just the existing reference' do
  all('.reference').size.should == 1
end

Then "I should not see any error messages" do
  page.should_not have_css '.error_messages li'
end

When /in the new edit form I fill in "(.*?)" with "(.*?)"/ do |field, value|
  within "#reference_" do
    When "I fill in \"#{field}\" with \"#{value}\""
  end
end

Then /in the new edit form the "(.*?)" field should (not )?contain "(.*?)"/ do |field, should_not, value|
  within "#reference_" do
    Then %{the "#{field}" field should #{should_not ? 'not ' : ''}contain "#{value}"}
  end
end

When /in the new edit form I follow "(.*?)"/ do |value|
  When "I follow \"#{value}\" within \"#reference_\""
end

When /in the new edit form I press the "(.*?)" button/ do |button|
  When "I press \"#{button}\" within \"#reference_\""
  sleep 3
end

When /in the new edit form I fill in "(.*?)" with the existing reference's ID/ do |field|
  When "in the new edit form I fill in \"#{field}\" with \"#{@reference.id}\""
end

Given 'I will confirm on the next step' do
  begin
    evaluate_script("window.alert = function(msg) { return true; }")
    evaluate_script("window.confirm = function(msg) { return true; }")
  rescue Capybara::NotSupportedByDriverError
  end
end

Then 'I should not see a "Delete" button' do
  find_button('Delete').should_not be_visible
end

Given 'I am not logged in' do
end

Given 'I log in' do
  When 'I go to the main page'
  User.delete_all
  @user = Factory :user
  click_link "Login"
  And %{I fill in "user_email" with "#{@user.email}"}
  And %{I fill in "user_password" with "#{@user.password}"}
  And %{I press "Go" within "#login"}
end

Given 'I log out' do
  Given %{I follow "Logout"}
end

Given 'I am logged in' do
  Given 'I log in'
end

Then 'I should not see the "Delete" button' do
  page.should_not have_css "button", :text => 'Delete'
end

Then /I should (not )?see a "PDF" link/ do |should_not|
  unless page.has_no_selector?('a', :text => 'PDF') and should_not
    find_link("PDF").send(should_not ? :should_not : :should, be_visible)
  end
end

When /^I press the "([^"]+)" button/ do |button|
  click_button button
  sleep 2
end

Then "I should see the reference's ID beside its label" do
  Then "I should see \"ID #{@reference.id}\""
end

When /I fill in "reference_nested_reference_id" with its own ID/ do
  When "I fill in \"reference_nested_reference_id\" with \"#{@reference.id}\""
end

When /I fill in "([^"]*)" with a URL to a document that exists/ do |field|
  stub_request :any, "google.com/foo"
  When "I fill in \"#{field}\" with \"google\.com/foo\""
end

When /I fill in "([^"]*)" with a URL to a document that doesn't exist/ do |field|
  stub_request(:any, "google.com/foo").to_return :status => 404
  When "I fill in \"#{field}\" with \"google\.com/foo\""
end

Given "there is a reference with ID 50000 for Dolerichoderinae" do
  Factory :unknown_reference, :id => 50000, :title => 'Dolerichoderinae'
end

When 'I choose a file to upload' do
  stub_request(:put, "http://s3.amazonaws.com/antcat/1/21105.pdf")
  attach_file 'reference_document_attributes_file', Rails.root + 'features/21105.pdf'
end

Then 'I should see a link to that file' do
  page.should have_css("a[href='http://127.0.0.1/documents/#{@reference.document.id}/21105.pdf']", :text => 'PDF')
end

Then 'I should be redirected to Amazon' do
end

Then 'I should see one duplicate reference' do
  all('.duplicate').size.should == 1
end

Then 'I should see one target reference' do
  all('.target').size.should == 1
end

Then /I should see the target reference "([^"]*)"/ do |target_reference|
  page.should have_css ".target", :text => target_reference
end

Then /^I should see the possible duplicate for it "([^"]*)" with similarity "([^"]*)"$/ do |duplicate, similarity|
  page.should have_css ".duplicate", :text => duplicate
  page.should have_css ".similarity", :text => similarity
end

Given /a (\w+) exists with a name of "([^"]+)" and a parent of "([^"]+)"/ do |rank, name, parent_name|
  Given %{a #{rank} exists with a name of "#{name}"}
  Taxon.find_by_name(name).update_attribute :parent, Taxon.find_by_name(parent_name)
end

When /I follow "All" in the subfamilies list/ do
  When %{I follow "All" within ".subfamilies"}
end

Then /"([^"]+)" should be selected/ do |word|
  page.should have_css ".selected", :text => word
end

And /I (edit|delete|copy) "(.*?)"/ do |verb, author|
  reference = Reference.where('author_names_string_cache like ?', "%#{author}%").first
  And %{I follow "#{verb}" within "#reference_#{reference.id}"}
end

Given /a subfamily exists with a name of "(.*?)" and a taxonomic history of "(.*?)"/ do |taxon_name, taxonomic_history|
  Factory :subfamily, :name => taxon_name, :taxonomic_history => taxonomic_history
end

Given /a genus exists with a name of "(.*?)"(?: and a subfamily of "(.*?)")?(?: and a taxonomic history of "(.*?)")?(?: and a status of "(.*?)")?/ do |taxon_name, parent_name, taxonomic_history, status|
  status ||= 'valid'
  subfamily = parent_name && (Subfamily.find_by_name(parent_name) || Factory(:subfamily, :name => parent_name))
  Factory :genus, :name => taxon_name, :subfamily => subfamily, :tribe => nil, :taxonomic_history => taxonomic_history, :status => status
end

Given /a species exists with a name of "(.*?)" and a genus of "(.*?)" and a taxonomic history of "(.*?)"/ do |taxon_name, parent_name, taxonomic_history|
  genus = Genus.find_by_name(parent_name) || Factory(:genus, :name => parent_name)
  Factory :species, :name => taxon_name, :genus => genus, :taxonomic_history => taxonomic_history
end

When /I fill in the search box with "(.*?)"/ do |search_term|
  When %{I fill in "q" with "#{search_term}"}
end

When /I press "Go" by the search box/ do
  When 'I press "Go" within "#search_form"'
end

Then /I should (not )?see the "add" icon/ do |do_not|
  selector = do_not ? :should_not : :should
  find("img[alt=add]").send selector, be_visible
end

Then /I should see "(.*?)" within (.*)$/ do |contents, location|
  with_scope location do
    When %{I should see "#{contents}"}
  end
end

And /I follow "(.*?)" within (.*)$/ do |link, location|
  with_scope location do
    When %{I follow "#{link}"}
  end
end

And /I press "(.*?)" within (.*)$/ do |button, location|
  with_scope location do
    When %{I press "#{button}"}
  end
end

And /I fill in "(.*?)" with "(.*?)" within (.*)$/ do |field, contents, location|
  with_scope location do
    When %{I fill in "#{field}" with "#{contents}"}
  end
end
