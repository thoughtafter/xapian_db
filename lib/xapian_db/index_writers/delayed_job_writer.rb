require 'xapian_db/index_writers/direct_writer'

module XapianDb
  module IndexWriters

    class DelayedJobWriter < DirectWriter
      class << self

        handle_asynchronously :index
        handle_asynchronously :delete_doc_with
        handle_asynchronously :reindex
        handle_asynchronously :reindex_class

      end
    end
  end
end
