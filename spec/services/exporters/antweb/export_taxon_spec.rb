require 'rails_helper'

describe Exporters::Antweb::ExportTaxon do
  include TestLinksHelpers

  describe "HEADER" do
    it "is the same as the code" do
      expected = "antcat id\t" \
        "subfamily\t" \
        "tribe\t" \
        "genus\t" \
        "subgenus\t" \
        "species\t" \
        "subspecies\t" \
        "author date\t" \
        "author date html\t" \
        "authors\t" \
        "year\t" \
        "status\t" \
        "available\t" \
        "current valid name\t" \
        "original combination\t" \
        "was original combination\t" \
        "fossil\t" \
        "taxonomic history html\t" \
        "reference id\t" \
        "bioregion\t" \
        "country\t" \
        "current valid rank\t" \
        "hol id\t" \
        "current valid parent"
      expect(described_class::HEADER).to eq expected
    end
  end

  describe "#call" do
    describe "[0]: `antcat_id`" do
      let(:taxon) { create :family }

      specify { expect(described_class[taxon][0]).to eq taxon.id }
    end

    describe "[1-6]: `subfamily`, ``tribe, `genus`, `subgenus`, `species` and `subspecies`" do
      let(:subfamily) { create :subfamily }
      let(:tribe) { create :tribe, subfamily: subfamily }

      it "can export a subfamily" do
        expect(described_class[subfamily][1..6]).to eq [
          subfamily.name_cache, nil, nil, nil, nil, nil
        ]
      end

      it "can export a genus" do
        genus = create :genus, subfamily: subfamily, tribe: tribe
        expect(described_class[genus][1..6]).to eq [
          subfamily.name_cache, tribe.name_cache, genus.name_cache, nil, nil, nil
        ]
      end

      it "can export a genus without a tribe" do
        genus = create :genus, subfamily: subfamily, tribe: nil
        expect(described_class[genus][1..6]).to eq [
          subfamily.name_cache, nil, genus.name_cache, nil, nil, nil
        ]
      end

      it "can export a genus without a subfamily as being in 'incertae_sedis'" do
        genus = create :genus, tribe: nil, subfamily: nil
        expect(described_class[genus][1..6]).to eq [
          'incertae_sedis', nil, genus.name_cache, nil, nil, nil
        ]
      end

      it "can export a Subgenus" do
        taxon = create :subgenus, name_string: 'Atta (Boyo)'
        expect(described_class[taxon][4]).to eq 'Boyo'
      end

      describe "Exporting species" do
        it "exports one correctly" do
          genus = create :genus, tribe: tribe
          species = create :species, name_string: 'Atta robustus', genus: genus

          expect(described_class[species][1..6]).to eq [
            subfamily.name_cache, tribe.name_cache, genus.name_cache, nil, 'robustus', nil
          ]
        end

        it "can export a species without a tribe" do
          genus = create :genus, subfamily: subfamily, tribe: nil
          species = create :species, name_string: 'Atta robustus', genus: genus

          expect(described_class[species][1..6]).to eq [
            subfamily.name_cache, nil, genus.name_cache, nil, 'robustus', nil
          ]
        end

        it "exports a species without a subfamily as being in the 'incertae sedis' subfamily" do
          genus = create :genus, subfamily: nil, tribe: nil
          species = create :species, name_string: 'Atta robustus', genus: genus

          expect(described_class[species][1..6]).to eq [
            'incertae_sedis', nil, genus.name_cache, nil, 'robustus', nil
          ]
        end
      end

      describe "Exporting subspecies" do
        it "exports one correctly" do
          genus = create :genus, subfamily: subfamily, tribe: tribe
          species = create :species, name_string: 'Atta robustus', subfamily: subfamily, genus: genus
          subspecies = create :subspecies, name_string: 'Atta robustus emeryii', subfamily: subfamily, genus: genus, species: species

          expect(described_class[subspecies][1..6]).to eq [
            subfamily.name_cache, tribe.name_cache, genus.name_cache, nil, 'robustus', 'emeryii'
          ]
        end

        it "can export a subspecies without a tribe" do
          genus = create :genus, subfamily: subfamily, tribe: nil
          species = create :species, name_string: 'Atta robustus', subfamily: subfamily, genus: genus
          subspecies = create :subspecies, name_string: 'Atta robustus emeryii', genus: genus, species: species

          expect(described_class[subspecies][1..6]).to eq [
            subfamily.name_cache, nil, genus.name_cache, nil, 'robustus', 'emeryii'
          ]
        end

        it "exports a subspecies without a subfamily as being in the 'incertae sedis' subfamily" do
          genus = create :genus, subfamily: nil, tribe: nil
          species = create :species, name_string: 'Atta robustus', subfamily: nil, genus: genus
          subspecies = create :subspecies, name_string: 'Atta robustus emeryii', subfamily: nil, genus: genus, species: species

          expect(described_class[subspecies][1..6]).to eq [
            'incertae_sedis', nil, genus.name_cache, nil, 'robustus', 'emeryii'
          ]
        end
      end
    end

    describe "[8]: `author date html`" do
      let(:taxon) { create :family }

      specify do
        reference = taxon.authorship_reference
        expect(described_class[taxon][8]).
          to eq %(<span title="#{reference.decorate.plain_text}">#{reference.keey}</span>)
      end
    end

    describe "[11]: `status`" do
      let(:taxon) { create :family }

      specify { expect(described_class[taxon][11]).to eq taxon.status }
    end

    describe "[12]: `available`" do
      context "when taxon is valid" do
        let(:taxon) { create :family }

        specify { expect(described_class[taxon][12]).to eq 'TRUE' }
      end

      context "when taxon is not valid" do
        let(:taxon) { create :family, :synonym }

        specify { expect(described_class[taxon][12]).to eq 'FALSE' }
      end
    end

    describe "[13]: `current valid name`" do
      context "when taxon dhas no `current_valid_taxon`" do
        let(:taxon) { create :genus }

        specify { expect(described_class[taxon][13]).to eq nil }
      end

      context "when taxon has a `current_valid_taxon`" do
        let!(:current_valid_taxon) { create :genus }
        let(:taxon) { create :genus, :synonym, current_valid_taxon: current_valid_taxon }

        it "exports the current valid name of the taxon" do
          expect(described_class[taxon][13]).to eq "#{taxon.subfamily.name.name} #{current_valid_taxon.name.name}"
        end
      end
    end

    # So that AntWeb knows when to use parentheses around authorship.
    describe "[14]: `original combination`" do
      specify do
        taxon = create :genus, :original_combination
        expect(described_class[taxon][14]).to eq 'TRUE'
      end

      specify do
        taxon = create :genus
        expect(described_class[taxon][14]).to eq 'FALSE'
      end
    end

    describe "[15]: `was original combination`" do
      context "when there was no recombining" do
        let(:taxon) { create :family }

        specify { expect(described_class[taxon][15]).to eq nil }
      end

      context "when there has been some recombining" do
        let(:recombination) { create :species }
        let(:original_combination) do
          create :species, :obsolete_combination, :original_combination, current_valid_taxon: recombination
        end

        before do
          recombination.protonym.name = original_combination.name
          recombination.save!
        end

        it "is the protonym" do
          expect(described_class[recombination][15]).to eq original_combination.name.name
        end
      end
    end

    describe "[16]: `fossil`" do
      context "when taxon is not fossil" do
        let(:taxon) { create :family }

        specify { expect(described_class[taxon][16]).to eq 'FALSE' }
      end

      context "when taxon is fossil" do
        let(:taxon) { create :family, :fossil }

        specify { expect(described_class[taxon][16]).to eq 'TRUE' }
      end
    end

    describe "[17]: `taxonomic history html` (child lists only)" do
      let!(:subfamily) { create :subfamily }
      let!(:tribe) { create :tribe, subfamily: subfamily }

      specify do
        expect(described_class[subfamily][17]).
          to include(%(<div><span class="caption">Tribes of #{subfamily.name_cache}</span>: #{antweb_taxon_link(tribe)}</div>))
      end
    end

    describe "[17]: `taxonomic history html`" do
      let!(:authorship_reference) do
        author_name = create :author_name, name: 'Bolton, B.'
        create :article_reference, author_names: [author_name],
          title: 'Ants I have known',
          citation_year: '2010a',
          journal: create(:journal, name: 'Psyche'),
          series_volume_issue: '1',
          pagination: '2'
      end
      let!(:protonym) do
        atta_name = create :genus_name, name: 'Atta'
        authorship = create :citation, reference: authorship_reference, pages: '12'
        create :protonym, name: atta_name, authorship: authorship
      end
      let!(:genus) { create :genus, name_string: 'Atta', protonym: protonym, hol_id: 9999 }
      let!(:type_species) { create :species, name_string: 'Atta major', genus: genus }
      let!(:a_reference) { create :article_reference, :with_doi }

      before do
        create :species, :unavailable, genus: genus # For the statistics.
        genus.update!(type_taxon: type_species, type_taxt: ', by monotypy')
        genus.history_items.create!(taxt: "Taxon: {tax #{type_species.id}}")
        genus.reference_sections.create!(title_taxt: "Title", references_taxt: "{ref #{a_reference.id}}: 766;")
      end

      it "formats a taxon's history for AntWeb" do
        ref_author = a_reference.authors_for_keey
        ref_year = a_reference.citation_year
        ref_title = a_reference.title
        ref_journal_name = a_reference.journal.name
        ref_pagination = a_reference.pagination
        ref_volume = a_reference.series_volume_issue
        ref_title_tag = "#{ref_author}, B.L. #{ref_year}. #{ref_title}. #{ref_journal_name} #{ref_volume}:#{ref_pagination}."
        ref_doi = a_reference.doi

        # rubocop:disable Layout/MultilineOperationIndentation
        expected =
          %(<div class="antcat_taxon">) +
            # statistics
            %(<p>Extant: 1 valid species</p>) +

            # headline
            %(<div>) +
              # protonym
              %(<b><i>Atta</i></b> ) +

              # authorship
              %(<a title="Bolton, B. 2010a. Ants I have known. Psyche 1:2." ) +
              %(href="http://antcat.org/references/#{authorship_reference.id}">Bolton, 2010a</a>) +
              %(: 12) +
              %(. ) +

              # type
              %(Type-species: #{antweb_taxon_link(type_species)}, by monotypy.) +
              %(  ) +

              # links
              %(#{antweb_taxon_link(genus, 'AntCat')} ) +
              %(<a class="external-link" href="http://www.antwiki.org/wiki/Atta">AntWiki</a> ) +
              %(<a class="external-link" href="http://hol.osu.edu/index.html?id=9999">HOL</a>) +
            %(</div>) +

            # taxonomic history
            %(<p><b>Taxonomic history</b></p>) +
            %(<div>) +
              %(<div>) +
                %(Taxon: #{antweb_taxon_link(type_species)}.) +
              %(</div>) +
            %(</div>) +

            # references
            %(<div>) +
              %(<div>) +
                %(<div>Title</div>) +
                %(<div>) +
                  %(<a title="#{ref_title_tag}" href="http://antcat.org/references/#{a_reference.id}">) +
                    %(#{ref_author}, #{ref_year}) +
                  %(</a> ) +
                  %(<a class="external-link" href="https://doi.org/#{ref_doi}">#{ref_doi}</a>) +
                  %(: 766;) +
                %(</div>) +
              %(</div>) +
            %(</div>) +
          %(</div>)
        # rubocop:enable Layout/MultilineOperationIndentation

        expect(described_class[genus][17]).to eq expected
      end
    end

    describe "[18]: `reference id`" do
      let(:taxon) { create :family }

      it "sends the protonym's reference ID" do
        expect(described_class[taxon][18]).to eq taxon.authorship_reference.id
      end
    end

    describe "[19]: `bioregion`" do
      let!(:protonym) { create :protonym, biogeographic_region: 'Neotropic' }
      let!(:taxon) { create :species, protonym: protonym }

      specify { expect(described_class[taxon][19]).to eq 'Neotropic' }
    end

    describe "[20]: `country`" do
      let!(:taxon) { create :genus, protonym: create(:protonym, locality: 'Canada') }

      specify { expect(described_class[taxon][20]).to eq 'Canada' }
    end

    describe "[21]: `current valid rank`" do
      let(:taxon) { create :subfamily }

      specify { expect(described_class[taxon][21]).to eq 'Subfamily' }
    end

    describe "[23]: `current valid parent`" do
      let(:subfamily) { create :subfamily }
      let(:tribe) { create :tribe, subfamily: subfamily }
      let(:genus) { create :genus, name_string: 'Atta', tribe: tribe, subfamily: subfamily }
      let(:subgenus) { create :subgenus, genus: genus, tribe: tribe, subfamily: subfamily }
      let(:species) { create :species, name_string: 'Atta betta', genus: genus, subfamily: subfamily }

      it "doesn't punt on a subfamily's family" do
        expect(described_class[subfamily][23]).to eq 'Formicidae'
      end

      it "handles a taxon's subfamily" do
        taxon = create :tribe, subfamily: subfamily
        expect(described_class[taxon][23]).to eq subfamily.name_cache
      end

      it "doesn't skip over tribe and return the subfamily" do
        taxon = create :genus, tribe: tribe
        expect(described_class[taxon][23]).to eq tribe.name_cache
      end

      it "returns the subfamily only if there's no tribe" do
        taxon = create :genus, subfamily: subfamily, tribe: nil
        expect(described_class[taxon][23]).to eq subfamily.name_cache
      end

      it "skips over subgenus parents" do
        taxon = create :species, genus: genus, subgenus: subgenus
        expect(described_class[taxon][23]).to eq genus.name_cache
      end

      it "handles a taxon's species" do
        taxon = create :subspecies, species: species
        expect(described_class[taxon][23]).to eq 'Atta betta'
      end

      it "handles a synonym" do
        senior = create :genus
        junior = create :genus, :synonym, current_valid_taxon: senior
        taxon = create :species, genus: junior

        expect(described_class[taxon][23]).to eq senior.name_cache
      end

      it "handles a genus without a subfamily" do
        taxon = create :genus, tribe: nil, subfamily: nil
        expect(described_class[taxon][23]).to eq 'Formicidae'
      end
    end
  end
end