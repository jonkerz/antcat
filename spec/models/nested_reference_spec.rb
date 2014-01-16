# coding: UTF-8
require 'spec_helper'

describe NestedReference do

  describe "validation" do
    before do
      @reference = NestedReference.new :title => 'asdf', :author_names => [FactoryGirl.create(:author_name)], :citation_year => '2010',
        :nester => FactoryGirl.create(:reference), :pages_in => 'Pp 2 in:'
    end
    it "should be valid with the attributes given above" do
      @reference.should be_valid
    end
    it "should not be valid without a nester" do
      @reference.nester = nil
      @reference.should_not be_valid
    end
    it "should be valid without a title" do
      @reference.title = nil
      @reference.should be_valid
    end
    it "should not be valid without a pages in" do
      @reference.pages_in = nil
      @reference.should_not be_valid
    end
    it "should refer to an existing reference" do
      @reference.nester_id = 232434
      @reference.should_not be_valid
    end
    it "should not point to itself" do
      @reference.nester_id = @reference.id
      @reference.should_not be_valid
    end
    it "should not point to something that points to itself" do
      inner_most = FactoryGirl.create :book_reference
      middle = FactoryGirl.create :nested_reference, :nester => inner_most
      top = FactoryGirl.create :nested_reference, :nester => middle
      middle.nester = top
      middle.should_not be_valid
    end
    it "can have a nester" do
      nester = FactoryGirl.create :reference
      nestee = FactoryGirl.create :nested_reference, nester: nester
      nestee.nester.should == nester
    end
  end

  describe "deletion" do
    it "should not be possible to delete a nestee" do
      reference = NestedReference.create! :title => 'asdf', :author_names => [FactoryGirl.create(:author_name)], :citation_year => '2010',
        :nester => FactoryGirl.create(:reference), :pages_in => 'Pp 2 in:'
      reference.nester.destroy.should be_false
    end

  end

end
