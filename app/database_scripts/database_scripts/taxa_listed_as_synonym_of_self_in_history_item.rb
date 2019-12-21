module DatabaseScripts
  class TaxaListedAsSynonymOfSelfInHistoryItem < DatabaseScript
    def results
      TaxonHistoryItem.joins(:taxon).where("taxt LIKE CONCAT('%synonym of {tax ', CONVERT(taxon_id, char), '}%') COLLATE utf8_unicode_ci")
    end

    def render
      as_table do |t|
        t.header :history_item, :taxon, :taxt
        t.rows do |history_item|
          [
            link_to(history_item.id, taxon_history_item_path(history_item)),
            markdown_taxon_link(history_item.taxon),
            Detax[history_item.taxt]
          ]
        end
      end
    end
  end
end

__END__

category: Taxt
tags: [new!]

description: >
  History items which contains `{tax <own id>}`. This list will contain false positives.
