require 'xapian_db/index_writers/direct_writer'

module XapianDb
  module IndexWriters

    class DelayedJobWriter < DirectWriter
      class << self

        # Reindex all objects of a given class
        # the reindex_class from DirectWriter will not work due to the manner
        # in which it batches transactions before commit.  This method utilizes
        # the TransactionalWriter to batch up 100 records at a time to index or
        # remove before committing.
        # @param [Class] klass The class to reindex
        # @param [Hash] options Options for reindexing
        # @option options [Boolean] :verbose (false) Should the reindexing give status informations?
        def reindex_class(klass, options={})
          opts = {:verbose => false}.merge(options)
          blueprint  = XapianDb::DocumentBlueprint.blueprint_for(klass)
          base_query = blueprint._base_query || klass
          show_progressbar = false
          obj_count = base_query.count

          if opts[:verbose]
            show_progressbar = defined?(ProgressBar)
            puts "reindexing #{obj_count} objects of #{klass}..."
            pbar = ProgressBar.new("Status", obj_count) if show_progressbar
          end

          base_query.find_in_batches(:batch_size=>100) do |batch|
            tw = TransactionalWriter.new
            batch.each do |obj|
              if blueprint.should_index?(obj)
                tw.index(obj)
              else
                tw.delete_doc_with(obj.xapian_id)
              end
              pbar.inc if show_progressbar
            end
            tw.delay.commit_using(DirectWriter)
          end
          true
        end

        def dj_priority
          0
        end

        handle_asynchronously :index, :priority=>Proc.new {|i| i.dj_priority }
        handle_asynchronously :delete_doc_with, :priority=>Proc.new {|i| i.dj_priority }
        handle_asynchronously :reindex_class, :priority=>Proc.new {|i| i.dj_priority }

      end
    end
  end
end
