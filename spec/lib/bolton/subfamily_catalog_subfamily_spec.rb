require 'spec_helper'

describe Bolton::SubfamilyCatalog do
  before do
    @subfamily_catalog = Bolton::SubfamilyCatalog.new
  end

  describe "Importing HTML" do
    def make_contents content
%{<html><body><div class=Section1>
<p class=MsoNormal align=center style='text-align:center'><b style='mso-bidi-font-weight:
normal'><span lang=EN-GB>THE DOLICHODEROMORPHS: SUBFAMILIES ANEURETINAE AND
DOLICHODERINAE<o:p></o:p></span></b></p>
#{content}
</div></body></html>}
    end

    it "should parse a subfamily" do
      @subfamily_catalog.should_receive(:parse_family).and_return {
        Factory :subfamily, :name => 'Aneuretinae'
        Factory :subfamily, :name => 'Dolichoderinae'
        Factory :subfamily, :name => 'Formicinae'
      }

      @subfamily_catalog.import_html make_contents %{
<p><b><span lang=EN-GB>SUBFAMILY <span style='color:red'>ANEURETINAE</span><o:p></o:p></span></b></p>

<p><span lang=EN-GB><o:p>&nbsp;</o:p></span></p>
<p><span lang=EN-GB><o:p>&nbsp;</o:p></span></p>

<p><b><span lang=EN-GB>Subfamily <span style='color:red'>ANEURETINAE</span> <o:p></o:p></span></b></p>
<p>Aneuritinae history</p>

<p><b><span lang=EN-GB>Tribes of Aneuretinae</span></b><span lang=EN-GB>: Aneuretini, *Pityomyrmecini.</span></p>
<p><b><span lang=EN-GB>Tribes <i>incertae sedis</i> in Aneuretinae</span></b><span lang=EN-GB>: *Miomyrmecini.</span></p>

<p><b><span lang=EN-GB>Genera (extinct) <i>incertae sedis</i> in Aneuretinae</span></b><span lang=EN-GB>: *<i>Burmomyrma, *Cananeuretus</i>. </span></p>
<p><b><span lang=EN-GB>Genus <i>incertae sedis</i> in Aneuretinae</span></b><span lang=EN-GB>: <i>Wildensis. </span></p>
<p><b><span lang=EN-GB>Hong (2002) genera (extinct) <i>incertae sedis</i> in Aneuretinae</span></b><span lang=EN-GB>: *<i>Curtipalpulus, *Eoleptocerites</i>.</span></p>

<p><b><span lang=EN-GB>Collective group name in Myrmeciinae</span></b><span lang=EN-GB>: *<i>Myrmeciites</i>.</span></p>

<p>References</p>
<p>a references</p>

<p><b><span lang=EN-GB>Tribe <span style='color:red'>ANEURETINI</span><o:p></o:p></span></b></p>
<p>Aneuretini history</p>

<p><b><span lang=EN-GB>Genus (extant) of Aneuretini</span></b><span lang=EN-GB>: <i>Aneuretus</i>.</span></p>

<p><b><span lang=EN-GB>Genera of <span style='color:red'>Aneuretini</span><o:p></o:p></span></b></p>
<p><span lang=EN-GB><o:p>&nbsp;</o:p></span></p>

<p><b><span lang=EN-GB>Genus <i><span style='color:red'>ANEURETUS</span></i> <o:p></o:p></span></b></p>
<p>Aneuretus history</p>

<p><b><span lang=EN-GB>Tribe <span style='color:red'>PITYOMYRMECINI</span><o:p></o:p></span></b></p>
<p>Pityomyrmecini history</p>

<p><b><span lang=EN-GB>Genera <i>incertae sedis</i> in <span style='color:red'>ANEURETINAE</span><o:p></o:p></span></b></p>
<p><span lang=EN-GB><o:p>&nbsp;</o:p></span></p>

<p><b><span lang=EN-GB>Genus *<i><span style='color:red'>BURMOMYRMA</span></i> <o:p></o:p></span></b></p>
<p>Burmomyrma history</p>

<p><b><span lang=EN-GB>SUBFAMILY <span style='color:red'>DOLICHODERINAE</span><o:p></o:p></span></b></p>
<p><b><span lang=EN-GB><o:p>&nbsp;</o:p></span></b></p>
<p><b><span lang=EN-GB><o:p>&nbsp;</o:p></span></b></p>

<p><b><span lang=EN-GB>Subfamily <span style='color:red'>DOLICHODERINAE</span> <o:p></o:p></span></b></p>
<p>Dolichoderinae history</p>

<p><b><span lang=EN-GB>THE FORMICOMORPHS: SUBFAMILY FORMICINAE<o:p></o:p></span></b></p>

<p><b><span lang=EN-GB>SUBFAMILY <span style='color:red'>FORMICINAE</span><o:p></o:p></span></b></p>
<p><b><span lang=EN-GB>Subfamily <span style='color:red'>FORMICINAE</span> <o:p></o:p></span></b></p>
<p>Formicinae history</p>

      }

      aneuretinae = Subfamily.find_by_name 'Aneuretinae'
      aneuretinae.taxonomic_history.should == '<p>Aneuritinae history</p>'

      aneuretini = Tribe.find_by_name 'Aneuretini'
      aneuretini.subfamily.should == aneuretinae
      aneuretini.should_not be_fossil
      aneuretini.taxonomic_history.should == '<p>Aneuretini history</p>'

      taxon = Tribe.find_by_name 'Pityomyrmecini'
      taxon.subfamily.should == aneuretinae
      taxon.should be_fossil
      taxon.taxonomic_history.should == '<p>Pityomyrmecini history</p>'

      taxon = Tribe.find_by_name 'Miomyrmecini'
      taxon.subfamily.should == aneuretinae
      taxon.incertae_sedis_in.should == 'subfamily'

      taxon = Genus.find_by_name 'Burmomyrma'
      taxon.subfamily.should == aneuretinae
      taxon.should be_fossil
      taxon.incertae_sedis_in.should == 'subfamily'
      taxon.should_not be_invalid
      taxon.taxonomic_history.should == '<p>Burmomyrma history</p>'

      taxon = Genus.find_by_name 'Cananeuretus'
      taxon.subfamily.should == aneuretinae
      taxon.should be_fossil
      taxon.incertae_sedis_in.should == 'subfamily'
      taxon.should_not be_invalid

      taxon = Genus.find_by_name 'Wildensis'
      taxon.subfamily.should == aneuretinae
      taxon.should_not be_fossil
      taxon.incertae_sedis_in.should == 'subfamily'
      taxon.should_not be_invalid

      taxon = Genus.find_by_name 'Curtipalpulus'
      taxon.subfamily.should == aneuretinae
      taxon.should be_fossil
      taxon.incertae_sedis_in.should == 'subfamily'
      taxon.should_not be_invalid

      taxon = Genus.find_by_name 'Eoleptocerites'
      taxon.subfamily.should == aneuretinae
      taxon.should be_fossil
      taxon.incertae_sedis_in.should == 'subfamily'
      taxon.should_not be_invalid

      taxon = Genus.find_by_name 'Myrmeciites'
      taxon.subfamily.should == aneuretinae
      taxon.should be_fossil
      taxon.should_not be_invalid

      taxon = Genus.find_by_name 'Aneuretus'
      taxon.subfamily.should == aneuretinae
      taxon.tribe.should == aneuretini
      taxon.should_not be_fossil
      taxon.should_not be_invalid
      taxon.taxonomic_history.should == '<p>Aneuretus history</p>'

      dolichoderinae = Subfamily.find_by_name 'Dolichoderinae'
      dolichoderinae.should_not be_invalid
      dolichoderinae.taxonomic_history.should == '<p>Dolichoderinae history</p>'

      taxon = Subfamily.find_by_name 'Formicinae'
      taxon.should_not be_invalid
      taxon.taxonomic_history.should == '<p>Formicinae history</p>'

    end

    it "should allow the genera header to be optional" do
      @subfamily_catalog.should_receive(:parse_family).and_return {
        Factory :subfamily, :name => 'Aneuretinae'
        Factory :subfamily, :name => 'Dolichoderinae'
      }

      @subfamily_catalog.import_html make_contents %{
<p><b><span lang=EN-GB>SUBFAMILY <span style='color:red'>ANEURETINAE</span><o:p></o:p></span></b></p>
<p><b><span lang=EN-GB>Subfamily <span style='color:red'>ANEURETINAE</span> <o:p></o:p></span></b></p>
<p><b><span lang=EN-GB>Tribes of Aneuretinae</span></b><span lang=EN-GB>: Aneuretini, *Pityomyrmecini.</span></p>
<p><b><span lang=EN-GB>Tribe <span style='color:red'>ANEURETINI</span><o:p></o:p></span></b></p>
<p><b><span lang=EN-GB>Genus of Aneuretini</span></b><span lang=EN-GB>: <i>Aneuretus</i>.</span></p>
<p><b><span lang=EN-GB>Genus <i><span style='color:red'>ANEURETUS</span></i> <o:p></o:p></span></b></p>
      }

      aneuretus = Genus.find_by_name "Aneuretus"
      aneuretus.tribe.name.should == 'Aneuretini'
    end

    it "should handle when a genus incertae sedis in subfamily also belongs to a tribe incertae sedis in subfamily (we're going to ignore the tribe" do
      @subfamily_catalog.should_receive(:parse_family).and_return { Factory :subfamily, :name => 'Dolichoderinae' }
      @subfamily_catalog.import_html make_contents %{
<p><b><span lang=EN-GB>SUBFAMILY <span style='color:red'>DOLICHODERINAE</span><o:p></o:p></span></b></p>
<p><b><span lang=EN-GB>Subfamily <span style='color:red'>DOLICHODERINAE</span> <o:p></o:p></span></b></p>
<p><b><span lang=EN-GB>Tribes (extinct) <i>incertae sedis</i> in Dolichoderinae</span></b><span lang=EN-GB>: *Miomyrmecini, *Zherichiniini.</span></p>
<p><b><span lang=EN-GB>Genera (extinct) <i>incertae sedis</i> in Dolichoderinae</span></b><span lang=EN-GB>: *<i>Miomyrmex</i>.</span></p>
<p><b><span lang=EN-GB>Tribe *<span style='color:red'>MIOMYRMECINI</span><o:p></o:p></span></b></p>
<p><b><span lang=EN-GB>Genus</span></b><span lang=EN-GB>: *<i>Miomyrmex</i> (see under: Genera <i>incertae sedis</i> in Dolichoderinae, below).</span></p>

<p><b><span lang=EN-GB>Genera (extinct) <i>incertae sedis</i> in <span style='color:red'>DOLICHODERINAE<o:p></o:p></span></span></b></p>
<p><b><span lang=EN-GB>Genus *<i><span style='color:red'>MIOMYRMEX</span></i> <o:p></o:p></span></b></p>
<p>Miomyrmex history</p>
      }
      miomyrmecini = Tribe.find_by_name 'Miomyrmecini'
      miomyrmecini.should_not be_nil
      miomyrmecini.incertae_sedis_in.should == 'subfamily'

      miomyrmex = Genus.find_by_name 'Miomyrmex'
      miomyrmex.should_not be_nil
      miomyrmex.incertae_sedis_in.should == 'subfamily'
      miomyrmex.tribe.should be_nil
    end

    describe "taxonomic history" do
      before do
        @subfamily_catalog.should_receive(:parse_family).and_return {Factory :subfamily, :name => 'Aneuretinae'}
        @contents = %{
  <p><b><span lang=EN-GB>SUBFAMILY <span style='color:red'>ANEURETINAE</span><o:p></o:p></span></b></p>
  <p><b><span lang=EN-GB>Subfamily <span style='color:red'>ANEURETINAE</span> <o:p></o:p></span></b></p>
        }
      end

      it "should handle a plus sign in the taxonomic history" do
        @subfamily_catalog.import_html make_contents @contents + '<p>Panama + Columbia</p>'
        Taxon.find_by_name('Aneuretinae').taxonomic_history.should == '<p>Panama + Columbia</p>'
      end

      it "should not translate &quot; character entity" do
        @subfamily_catalog.import_html make_contents @contents + '<p>&quot;XXX</p>'
        Taxon.find_by_name('Aneuretinae').taxonomic_history.should == '<p>&quot;XXX</p>'
      end

    end
  end
end
