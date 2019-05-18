module DatabaseScripts
  class PassThroughNamesWithTaxts < DatabaseScript
    def results
      Taxon.pass_through_names.left_outer_joins(:history_items, :reference_sections).
        distinct.where("taxon_history_items.id IS NOT NULL OR reference_sections.id IS NOT NULL")
    end
  end
end

__END__
description: >
  Original combinations, obsolete combination and unavailable misspellings with
  history items or reference sections.


  See also [Pass through names with synonyms](/database_scripts/pass_through_names_with_synonyms).


  See %github375.

topic_areas: [synonyms]
tags: [regression-test]
issue_description: This taxon is a "pass-through name", but is has history items or reference sections.
