require "spec_helper"

describe Autocomplete::AutocompleteLinkableReferences do
  describe "#call" do
    it 'calls `References::Search::FulltextLight`' do
      search_query = 'Bolton'
      expect(References::Search::FulltextLight).to receive(:new).with(search_query).and_call_original
      described_class[search_query]
    end

    context "when there are results", :search do
      let!(:reference) { create :reference, author_name: "Bolton" }

      before { Sunspot.commit }

      specify { expect(described_class["Bolton"]).to eq Autocomplete::FormatLinkableReferences[[reference]] }
    end

    context 'when a reference ID is given' do
      let!(:reference) { create :unknown_reference }

      specify do
        expect(described_class[reference.id.to_s]).to eq(Autocomplete::FormatLinkableReferences[[reference]])
      end
    end
  end
end
