require "spec_helper"

describe References::Cache::Invalidate do
  describe "#call" do
    let(:reference) { create :article_reference }

    it "nilifies caches" do
      References::Cache::Regenerate[reference]
      expect(reference.plain_text_cache).not_to be_nil
      expect(reference.expandable_reference_cache).not_to be_nil
      expect(reference.expanded_reference_cache).not_to be_nil

      described_class[reference]

      expect(reference.plain_text_cache).to be_nil
      expect(reference.expandable_reference_cache).to be_nil
      expect(reference.expanded_reference_cache).to be_nil
    end

    context "when reference has nestees" do
      let!(:nestee) { create :nested_reference, nesting_reference: reference }

      it "nilifies caches for its nestees" do
        expect(reference.reload.nestees).to eq [nestee]

        References::Cache::Regenerate[nestee]
        expect(nestee.plain_text_cache).not_to be_nil
        expect(nestee.expandable_reference_cache).not_to be_nil
        expect(nestee.expanded_reference_cache).not_to be_nil

        described_class[reference]
        nestee.reload

        expect(nestee.plain_text_cache).to be_nil
        expect(nestee.expandable_reference_cache).to be_nil
        expect(nestee.expanded_reference_cache).to be_nil
      end
    end
  end
end
