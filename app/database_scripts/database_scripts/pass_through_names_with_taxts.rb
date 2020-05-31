# frozen_string_literal: true

module DatabaseScripts
  class PassThroughNamesWithTaxts < DatabaseScript
    def results
      TaxonQuery.new.pass_through_names.left_outer_joins(:history_items, :reference_sections).
        distinct.where("taxon_history_items.id IS NOT NULL OR reference_sections.id IS NOT NULL")
    end

    def render
      as_table do |t|
        t.header 'Taxon', 'Rank', 'Status'
        t.rows do |taxon|
          [
            taxon_link(taxon),
            taxon.rank,
            taxon.status
          ]
        end
      end
    end
  end
end

__END__

title: Pass-through names with taxts

section: regression-test
category: Catalog
tags: []

issue_description: This taxon is a "pass-through name", but is has history items or reference sections.

description: >
  Obsolete combination and unavailable misspellings with
  history items or reference sections.


  See %github375.
