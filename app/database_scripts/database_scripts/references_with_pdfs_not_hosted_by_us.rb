module DatabaseScripts
  class ReferencesWithPdfsNotHostedByUs < DatabaseScript
    def results
      Reference.left_outer_joins(:document).
        where.not(reference_documents: { url: [nil, ''] }).
        where("url NOT LIKE ?", "%antcat.org/documents%").
        no_missing.order_by_author_names_and_year.
        includes(:author_names).references(:reference_author_names)
    end

    def render
      as_table do |t|
        t.header :reference, :url, :protonym_reference?
        t.rows do |reference|
          [
            link_to(reference.keey, reference_path(reference)),
            link_to(reference.document.url, reference.document.url),
            ('Yes' if reference.protonyms.any?)
          ]
        end
      end
    end
  end
end

__END__

title: References with PDFs not hosted by us
category: PDFs
tags: [slow-render]

description: >
  There may be more references not hosted by us, but these definitely are not.


  These can be uploaded via script (TODO: write script).


  Issues: %github387, %github324, %github371

related_scripts:
  - OrphanedReferenceDocuments
  - ProtonymReferencesWithoutPdfs
  - ReferencesWithBlankPdfUrlsAndFilenames
  - ReferencesWithoutPdfs
  - ReferencesWithPdfsNotHostedByUs
  - ReferencesWithUndownloadablePdfs