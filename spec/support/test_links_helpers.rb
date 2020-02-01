module TestLinksHelpers
  def author_link author_name
    %(<a href="/authors/#{author_name.author.id}">#{author_name.name}</a>)
  end

  def taxon_link taxon, label = nil
    %(<a href="/catalog/#{taxon.id}">#{label || taxon.name_with_fossil}</a>)
  end

  def taxon_link_with_author_citation taxon
    %(<a href="/catalog/#{taxon.id}">#{taxon.name_with_fossil}</a> #{taxon.author_citation})
  end

  def antweb_taxon_link taxon, label = nil
    %(<a href="http://www.antcat.org/catalog/#{taxon.id}">#{label || taxon.name_with_fossil}</a>)
  end
end