module XapianDb
  module IndexWriters

    class DelayedJobWriter < DirectWriter
      class << self

        # Update an object in the index
        # @param [Object] obj An instance of a class with a blueprint configuration
        def index(obj, commit=true)
          super.delay.index(obj, commit)
        end

        # Remove an object from the index
        # @param [String] xapian_id The document id of an object
        def delete_doc_with(xapian_id, commit=true)
          super.delay.delete_doc_with(xapian_id, commit)
        end

        # Update or delete a xapian document belonging to an object depending on the ignore_if logic(if present)
        # @param [Object] object An instance of a class with a blueprint configuration
        def reindex(object, commit=true)
          super.delay.reindex(object, commit)
        end

        # Reindex all objects of a given class
        # @param [Class] klass The class to reindex
        # @param [Hash] options Options for reindexing
        # @option options [Boolean] :verbose (false) Should the reindexing give status informations?
        def reindex_class(klass, options={})
          super.delay.reindex_class(klass, options)
        end

      end
    end
  end
end