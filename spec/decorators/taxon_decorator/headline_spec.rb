require "spec_helper"

describe TaxonDecorator::Headline do
  describe "#link_to_other_site" do
    context "when species" do
      let(:species) do
        subfamily = create_subfamily 'Dolichoderinae'
        genus = create_genus 'Atta', subfamily: subfamily
        create_species 'Atta major', genus: genus, subfamily: subfamily
      end

      specify do
        expect(described_class.new(species).send(:link_to_other_site)).to eq %{<a class="link_to_external_site" href="http://www.antweb.org/description.do?rank=species&genus=atta&species=major&project=worldants">AntWeb</a>}
      end
    end

    context "when subspecies" do
      let(:subspecies) do
        subfamily = create_subfamily 'Dolichoderinae'
        genus = create_genus 'Atta', subfamily: subfamily
        species = create_species 'Atta major', genus: genus, subfamily: subfamily
        create_subspecies 'Atta major nigrans', species: species, genus: genus, subfamily: subfamily
      end

      specify do
        expect(described_class.new(subspecies).send(:link_to_other_site))
          .to eq %{<a class="link_to_external_site" href="http://www.antweb.org/description.do?rank=subspecies&genus=atta&species=major&subspecies=nigrans&project=worldants">AntWeb</a>}
      end
    end

    context "when invalid taxa" do
      let(:subfamily) { create_subfamily 'Dolichoderinae', status: 'synonym' }

        specify do
          expect(described_class.new(subfamily).send(:link_to_other_site)).not_to be_nil
        end
    end
  end
end