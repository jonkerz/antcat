module DatabaseScripts
  class ValidTaxaWithAHomonymReplacedById < DatabaseScript
    def results
      Taxon.valid.where.not(homonym_replaced_by: nil)
    end

    def render
      as_table do |t|
        t.header :taxon, :status, :homonym_replaced_by, :homonym_replaced_by_status

        t.rows do |taxon|
          [ markdown_taxon_link(taxon),
            taxon.status,
            markdown_taxon_link(taxon.homonym_replaced_by),
            taxon.homonym_replaced_by.status ]
        end
      end
    end
  end
end

__END__
topic_areas: [catalog]