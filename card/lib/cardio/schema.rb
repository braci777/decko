module Cardio
  module Schema
    def assume_migrated_upto_version type
      Cardio.schema_mode(type) do
        ActiveRecord::Schema.assume_migrated_upto_version(
          Cardio.schema(type), Cardio.migration_paths(type)
        )
      end
    end

    def schema_suffix type
      case type
      when :core_cards then "_core_cards"
      when :deck_cards then "_deck_cards"
      else ""
      end
    end

    def schema_mode type
      with_suffix type do
        paths = Cardio.migration_paths(type)
        yield(paths)
      end
    end

    def with_suffix mig_type
      original_name = ActiveRecord::Base.schema_migrations_table_name
      #original_suffix = ActiveRecord::Base.table_name_suffix
      #ActiveRecord::Base.table_name_suffix = new_suffix
      ActiveRecord::Base.schema_migrations_table_name += schema_suffix mig_type
      ActiveRecord::SchemaMigration.reset_table_name
      yield
      #ActiveRecord::Base.table_name_suffix = original_suffix
      ActiveRecord::Base.schema_migrations_table_name = original_name
      ActiveRecord::SchemaMigration.reset_table_name
    end

    # def schema_mode type
    #   paths = Cardio.migration_paths(type)
    #   with_suffix type do
    #     ActiveRecord::SchemaMigration.reset_table_name
    #     yield(paths)
    #     ActiveRecord::SchemaMigration.reset_table_name
    #   end
    # end
    #
    # def with_suffix type
    #   new_suffix = Cardio.schema_suffix type
    #   original_suffix = ActiveRecord::Base.table_name_suffix
    #   ActiveRecord::Base.table_name_suffix = new_suffix
    #   yield
    #   ActiveRecord::Base.table_name_suffix = original_suffix
    # end

    def schema type=nil
      File.read(schema_stamp_path(type)).strip
    end

    def schema_stamp_path type
      root_dir = (type == :deck_cards ? root : gem_root)
      stamp_dir = ENV["SCHEMA_STAMP_PATH"] || File.join(root_dir, "db")

      File.join stamp_dir, "version#{schema_suffix type}.txt"
    end
  end
end
