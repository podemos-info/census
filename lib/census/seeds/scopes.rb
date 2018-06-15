# frozen_string_literal: true

require "csv"

module Census
  module Seeds
    class Scopes
      def seed(options = {})
        base_path = options[:base_path]

        puts "Loading scope types..."
        save_scope_types("#{base_path}/scope_types.tsv")

        puts "Loading scopes..."
        if File.exist?(cache_path)
          load_cached_scopes(cache_path)
        else
          load_original_scopes("#{base_path}/scopes.tsv", "#{base_path}/scopes.translations.tsv", "#{base_path}/scopes.mappings.tsv", "#{base_path}/scopes.metadata.tsv")
          cache_scopes(cache_path)
        end
      end

      def cache_path
        @cache_path ||= ENV["SCOPES_CACHE_PATH"].presence || Rails.root.join("tmp", "cache", "#{Rails.env}_scopes.csv")
      end

      private

      def save_scope_types(source)
        @scope_types = Hash.new { |h, k| h[k] = Hash.new { |h2, k2| h2[k2] = {} } }
        CSV.foreach(source, col_sep: "\t", headers: true) do |row|
          @scope_types[row["Code"]][:id] = row["UID"]
          @scope_types[row["Code"]][:name][row["Locale"]] = row["Singular"]
          @scope_types[row["Code"]][:plural][row["Locale"]] = row["Plural"]
        end

        ScopeType.transaction do
          @scope_types.each_value do |info|
            ScopeType.find_or_initialize_by(id: info[:id]).update!(info)
          end
          max_id = ScopeType.maximum(:id)
          ScopeType.connection.execute(ActiveRecord::Base.sanitize_sql_array(["ALTER SEQUENCE scope_types_id_seq RESTART WITH ?", max_id + 1]))
        end
      end

      def load_original_scopes(main_source, translations_source, mappings_source, metadata_source)
        @translations = Hash.new { |h, k| h[k] = {} }
        CSV.foreach(translations_source, col_sep: "\t", headers: true) do |row|
          @translations[row["UID"]][row["Locale"]] = row["Translation"]
        end

        @mappings = Hash.new { |h, k| h[k] = {} }
        CSV.foreach(mappings_source, col_sep: "\t", headers: true) do |row|
          @mappings[row["UID"]][row["Encoding"]] = row["Code"]
        end

        @metadata = Hash.new { |h, k| h[k] = {} }
        CSV.foreach(metadata_source, col_sep: "\t", headers: true) do |row|
          @metadata[row["UID"]][row["Key"]] = row["Value"]
        end

        @scope_ids = {}
        CSV.foreach(main_source, col_sep: "\t", headers: true) do |row|
          save_scope row
        end
      end

      def load_cached_scopes(source)
        conn = ActiveRecord::Base.connection.raw_connection
        File.open(source, "r:ASCII-8BIT") do |file|
          conn.copy_data "COPY scopes FROM STDOUT With CSV HEADER DELIMITER E'\t' NULL '' ENCODING 'UTF8'" do
            conn.put_copy_data(file.readline) until file.eof?
          end
        end
      end

      def cache_scopes(target)
        conn = ActiveRecord::Base.connection.raw_connection
        File.open(target, "w:ASCII-8BIT") do |file|
          conn.copy_data "COPY (SELECT * FROM scopes) To STDOUT With CSV HEADER DELIMITER E'\t' NULL '' ENCODING 'UTF8'" do
            while (row = conn.get_copy_data) do file.puts row end
          end
        end
      end

      def parent_code(code)
        return nil if code == Scope.local_code
        parent_code = code.rindex(/\W/i)
        parent_code ? code[0..parent_code - 1] : Scope.non_local_code
      end

      def save_scope(row)
        print "#{row["UID"].ljust(30)}\r"
        code = row["UID"]

        scope = Scope.find_or_initialize_by(code: code)

        scope.scope_type_id = @scope_types[row["Type"]][:id]
        scope.name = @translations[code]
        scope.parent_id = @scope_ids[parent_code(code)]
        scope.mappings = @mappings[code]
        scope.metadata = @metadata[code]

        scope.save!
        @scope_ids[code] = scope.id
      end
    end
  end
end
