# frozen_string_literal: true

module Census
  module Seeds
    class Scopes
      def self.seed(options = {})
        Scopes.new.seed options
      end

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
          @scope_types.values.each do |info|
            ScopeType.find_or_initialize_by(id: info[:id]).update_attributes!(info)
          end
        end

        @translations = Hash.new { |h, k| h[k] = {} }
        CSV.foreach(File.join(path, "scopes.translations.tsv"), col_sep: "\t", headers: true) do |row|
          @translations[row["UID"]][row["Locale"]] = row["Translation"]
        end

        puts "Loading scopes..."
        @scope_ids = {}
        scopes = []
        CSV.foreach(File.join(path, "scopes.tsv"), col_sep: "\t", headers: true) do |row|
          scopes << row
          if scopes.count > batch_size
            save_scopes scopes
            scopes = []
          end
        end
      end

      private

      def root_code(code)
        code.split(/\W/i).first
      end

      def parent_code(code)
        parent_code = code.rindex(/\W/i)
        parent_code ? code[0..parent_code - 1] : nil
      end

      def save_scopes(scopes)
        Scope.transaction do
          scopes.each do |row|
            print "\r#{row["UID"].ljust(30)}"
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
