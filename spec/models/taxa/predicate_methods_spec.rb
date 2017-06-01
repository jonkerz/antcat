describe Taxon do
  let(:taxon) { build_stubbed :taxon }

  context "when status 'valid'" do
    it "is not invalid" do
      taxon.status = "valid"
      expect(taxon).not_to be_invalid
    end
  end

  it "can be unidentifiable" do
    expect(taxon).not_to be_unidentifiable
    taxon.status = 'unidentifiable'
    expect(taxon).to be_unidentifiable
    expect(taxon).to be_invalid
  end

  it "can be a collective group name" do
    expect(taxon).not_to be_collective_group_name
    taxon.status = 'collective group name'
    expect(taxon).to be_collective_group_name
    expect(taxon).to be_invalid
  end

  it "can be an ichnotaxon" do
    expect(taxon).not_to be_ichnotaxon
    taxon.ichnotaxon = true
    expect(taxon).to be_ichnotaxon
    expect(taxon).not_to be_invalid
  end

  it "can be unavailable" do
    expect(taxon).not_to be_unavailable
    expect(taxon).to be_available
    taxon.status = 'unavailable'
    expect(taxon).to be_unavailable
    expect(taxon).not_to be_available
    expect(taxon).to be_invalid
  end

  it "can be excluded from Formicidae" do
    expect(taxon).not_to be_excluded_from_formicidae
    taxon.status = 'excluded from Formicidae'
    expect(taxon).to be_excluded_from_formicidae
    expect(taxon).to be_invalid
  end

  it "can be a fossil" do
    expect(taxon).not_to be_fossil
    expect(taxon.fossil).to eq false
    taxon.fossil = true
    expect(taxon).to be_fossil
  end

  describe "#recombination?" do
    context "name is same as protonym" do
      it "it is not a recombination" do
        species = create_species 'Atta major'
        protonym_name = create_species_name 'Atta major'

        expect(species.protonym).to receive(:name).and_return protonym_name
        expect(species).not_to be_recombination
      end
    end

    context "genus part of name is different than genus part of protonym" do
      it "it is a recombination" do
        species = create_species 'Atta minor'
        protonym_name = create_species_name 'Eciton minor'

        expect(species.protonym).to receive(:name).and_return protonym_name
        expect(species).to be_recombination
      end
    end

    context "genus part of name is same as genus part of protonym" do
      it "it is not a recombination" do
        species = create_species 'Atta minor maxus'
        protonym_name = create_subspecies_name 'Atta minor minus'

        expect(species.protonym).to receive(:name).and_return protonym_name
        expect(species).not_to be_recombination
      end
    end
  end

  describe "#incertae_sedis_in" do
    let(:myanmyrma) { build_stubbed :taxon, incertae_sedis_in: 'family' }

    it "can have an incertae_sedis_in" do
      expect(myanmyrma.incertae_sedis_in).to eq 'family'
      expect(myanmyrma).not_to be_invalid
    end

    it "can say whether it is incertae sedis in a particular rank" do
      expect(myanmyrma).to be_incertae_sedis_in 'family'
    end
  end
end