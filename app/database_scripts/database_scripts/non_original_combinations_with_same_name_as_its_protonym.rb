# frozen_string_literal: true

module DatabaseScripts
  class NonOriginalCombinationsWithSameNameAsItsProtonym < DatabaseScript
    def results
      Taxon.joins(:name, protonym: :name).
        obsolete_combinations.
        where.not(original_combination: true).
        where("names.name = names_protonyms.name")
    end

    def render
      as_table do |t|
        t.header 'Taxon', 'Status', 'Protonym'
        t.rows do |taxon|
          [
            markdown_taxon_link(taxon),
            taxon.status,
            taxon.protonym.decorate.link_to_protonym
          ]
        end
      end
    end
  end
end

__END__

title: Non-original combinations with same name as its protonym
category: Catalog
tags: [regression-test]

issue_description: This obsolete combination has the same name as its protonym, but "Original combination" is not checked.

description: >
  Taxa where `original_combination` is checked are not included. Check it in the taxon form to clear a taxon from this script


  Only taxa with the status "original combination" are included here.


  Can be fixed by script if all taxa should be changed to have the `original_combination` flag.

related_scripts:
  - NonOriginalCombinationsWithSameNameAsItsProtonym
  - ProtonymsNoOriginalCombination
  - ProtonymsWithMoreThanOneOriginalCombination
