# frozen_string_literal: true

module Census
  module Seeds
    def self.seed_scopes(options = {})
      Scopes.new.seed options
    end

    class Scopes
      EXTERIOR_SCOPE = "XX"
      CACHE_PATH = Rails.root.join("tmp", "cache", "scopes.csv").freeze

      def seed(options = {})
        path = File.join(options[:base_path], "scopes")
        batch_size = options[:batch_size] || 500

        @scope_types = Hash.new { |h, k| h[k] = Hash.new { |h2, k2| h2[k2] = {} } }
        CSV.foreach(File.join(path, "scope_types.tsv"), col_sep: "\t", headers: true) do |row|
          @scope_types[row["Code"]][:id] = row["UID"]
          @scope_types[row["Code"]][:name][row["Locale"]] = row["Singular"]
          @scope_types[row["Code"]][:plural][row["Locale"]] = row["Plural"]
        end

        ScopeType.transaction do
          @scope_types.each_value do |info|
            ScopeType.find_or_initialize_by(id: info[:id]).update!(info)
          end
          max_id = ScopeType.maximum(:id)
          ScopeType.connection.execute("ALTER SEQUENCE scope_types_id_seq RESTART WITH #{max_id + 1}")
        end

        @translations = Hash.new { |h, k| h[k] = {} }
        CSV.foreach(File.join(path, "scopes.translations.tsv"), col_sep: "\t", headers: true) do |row|
          @translations[row["UID"]][row["Locale"]] = row["Translation"]
        end

        puts "Loading scopes..."
        return if load_cached_scopes

        @scope_ids = {}
        scopes = []
        CSV.foreach(File.join(path, "scopes.tsv"), col_sep: "\t", headers: true) do |row|
          scopes << row
          if scopes.count > batch_size
            save_scopes scopes
            scopes = []
          end
        end
        save_scopes scopes
      end

      def self.cache_scopes
        conn = ActiveRecord::Base.connection.raw_connection
        File.open(Census::Seeds::Scopes::CACHE_PATH, "w:ASCII-8BIT") do |file|
          conn.copy_data "COPY (SELECT * FROM scopes) To STDOUT With CSV HEADER DELIMITER E'\t' NULL '' ENCODING 'UTF8'" do
            while (row = conn.get_copy_data) do file.puts row end
          end
        end
      end

      private

      def load_cached_scopes
        return unless File.exist?(CACHE_PATH)

        conn = ActiveRecord::Base.connection.raw_connection
        File.open(Census::Seeds::Scopes::CACHE_PATH, "r:ASCII-8BIT") do |file|
          conn.copy_data "COPY scopes FROM STDOUT With CSV HEADER DELIMITER E'\t' NULL '' ENCODING 'UTF8'" do
            conn.put_copy_data(file.readline) until file.eof?
          end
        end
        true
      end

      def parent_code(code)
        return nil if code == Scope.local_code
        parent_code = code.rindex(/\W/i)
        parent_code ? code[0..parent_code - 1] : EXTERIOR_SCOPE
      end

      def save_scopes(scopes)
        Scope.transaction do
          scopes.each do |row|
            print "#{row["UID"].ljust(30)}\r"
            code = row["UID"]

            scope = Scope.find_or_initialize_by(code: code)

            scope.scope_type_id = @scope_types[row["Type"]][:id]
            scope.name = @translations[code]
            scope.parent_id = @scope_ids[parent_code(code)]

            scope.save!
            @scope_ids[code] = scope.id
          end
        end
      end
    end
  end
end
