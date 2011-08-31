module Picky

  module Backends

    class File

      # File-based index files dumped in the JSON format.
      #
      class JSON < Basic

        # The in-memory mapping hash, mapping
        # a Symbol key to [length, offset] of
        # the JSON data in the file.
        #
        attr_accessor :mapping

        # See lib/picky/backends/file.rb for what this should return.
        #
        # 1. Gets the length and offset for the key.
        # 2. Extracts and decodes the object from the file.
        #
        def [] key
          length, offset = mapping[key]
          return unless length
          result = Yajl::Parser.parse IO.read(cache_path, length, offset)
          result
        end

        # Clears the currently loaded index.
        #
        # Note: This only clears the in-memory mapping,
        #       but this is enough for the index to not exist
        #       anymore, at least to the application.
        #
        def clear
          self.mapping.clear
        end

        # Loads the mapping hash from json format.
        #
        def load
          self.mapping = mapping_file.load
          self
        end

        # Dumps the index hash in json format.
        #
        # 1. Dump actual data.
        # 2. Dumps mapping key => [length, offset].
        #
        def dump hash
          offset = 0
          mapping = {}

          ::File.open(cache_path, 'w:utf-8') do |out_file|
            hash.each do |(key, object)|
              encoded = Yajl::Encoder.encode object
              length  = encoded.size
              mapping[key] = [length, offset]
              offset += length
              out_file.write encoded
            end
          end

          mapping_file.dump mapping
        end

        # A json file does not provide retrieve functionality.
        #
        def retrieve
          raise "Can't retrieve from JSON file. Use text file."
        end

        # Uses the extension "json".
        #
        def extension
          :json
        end

        # Will copy the index file to a location that
        # is in a directory named "backup" right under
        # the directory the index file is in.
        #
        def backup
          mapping_file.backup

          prepare_backup backup_directory(cache_path)
          FileUtils.cp cache_path, target, verbose: true
        end

        # Copies the file from its backup location back
        # to the original location.
        #
        def restore
          mapping_file.restore

          FileUtils.cp backup_file_path_of(cache_path), cache_path, verbose: true
        end

        # Deletes the file.
        #
        def delete
          mapping_file.delete

          `rm -Rf #{cache_path}`
        end

        # Is this cache file suspiciously small?
        # (less than 8 Bytes of size)
        #
        def cache_small?
          size_of(cache_path) < 8
        end

        # Is the cache ok? (existing and larger than
        # zero Bytes in size)
        #
        # A small cache is still ok.
        #
        def cache_ok?
          size_of(cache_path) > 0
        end

      end

    end

  end

end