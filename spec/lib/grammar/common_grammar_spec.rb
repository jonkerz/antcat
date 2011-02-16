require 'spec_helper'

describe CommonGrammar do
  describe "parsing a blank line" do
    it "should not consider a nonblank line blank" do
      lambda {CommonGrammar.parse(%{  a  }, :root => :blank_line)}.should raise_error Citrus::ParseError
      CommonGrammar.parse(%{  a  }, :root => :nonblank_line).value.should == :nonblank_line
    end

    it "should handle '<p> </p>' (nested empty paragraph)" do
      CommonGrammar.parse(%{<p> </p>}, :root => :blank_line).value.should == :blank_line
    end

    it "should handle a nonbreaking space inside a subparagraph" do
      CommonGrammar.parse(%{<span style="mso-spacerun: yes">&nbsp;</span>}, :root => :blank_line).value.should == :blank_line
    end

    it "should handle a nonbreaking space inside a subparagraph" do
      CommonGrammar.parse(%{<p> </p>}, :root => :blank_line).value.should == :blank_line
    end
    it "should handle a nonbreaking space" do
      CommonGrammar.parse(%{ }, :root => :blank_line).value.should == :blank_line
    end
    it "should handle a spacerun" do
      CommonGrammar.parse(%{<span style="mso-spacerun: yes"> </span>}, :root => :blank_line).value.should == :blank_line
    end
    it "should handle an empty paragraph with a font" do
      CommonGrammar.parse(%{<span style='font-family:"Times New Roman"'><p> </p></span>}, :root => :blank_line).value.should == :blank_line
    end
    it "should handle an empty paragraph with italics" do
      CommonGrammar.parse(%{<i><p> </p></i>}, :root => :blank_line).value.should == :blank_line
    end
    it "should handle a blank bold red paragraph" do
      CommonGrammar.parse(%{<b><span style="color:red"><p> </p></span></b>}, :root => :blank_line).value.should == :blank_line
    end
    it "should handle a namespaced paragraph with a blank" do
      CommonGrammar.parse(%{<o:p>&nbsp;</o:p>}, :root => :blank_line).value.should == :blank_line
    end
    it "should handle a nonbreaking space inside paragraph" do
      CommonGrammar.parse(%{<p>&nbsp;</p>}, :root => :blank_line).value.should == :blank_line
    end

  end
end
