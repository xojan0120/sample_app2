# used to alter columns in postgresql
module AlterColumn
  def alter_column(table_name, column_name, new_type, mapping, default = nil)
    drop_default = %Q{ALTER TABLE #{table_name} ALTER COLUMN #{column_name} DROP DEFAULT;}
    execute(drop_default)
    # puts drop_default

    base = %Q{ALTER TABLE #{table_name} ALTER COLUMN #{column_name} TYPE #{new_type} }
    if mapping.kind_of?(Hash)
      contains_else = mapping.has_key?("else")
      else_mapping = mapping.delete("else")
      when_mapping = mapping.map { |k, v| "when '#{k}' then #{v}" }.join("\n")
      
      base += %Q{ USING CASE #{column_name} #{when_mapping} } unless when_mapping.blank?
      base += %Q{ ELSE #{else_mapping} } unless contains_else.blank?
      base += %Q{ END } if !when_mapping.blank? or !contains_else.blank?
    elsif mapping.kind_of?(String)
      base += mapping
    end
    base += ";"
    
    execute(base);
    # puts base
    
    unless default.blank?
      set_default = %Q{ALTER TABLE #{table_name} ALTER COLUMN #{column_name} SET DEFAULT #{default};}
      execute(set_default)
      # puts set_default
    end
  end
  module_function :alter_column
end

class ChangeIntegerReceiverIdOfDirectMessages < ActiveRecord::Migration[5.1]
  class << self
    include AlterColumn
  end
  def self.up
    if ActiveRecord::Base.connection_config[:adapter] == "postgresql"
      alter_column :direct_messages, :receiver_id, :integer, "USING CAST(receiver_id AS integer)", 1
    else
      change_column :direct_messages, :receiver_id, :integer
    end
  end
  def self.down
    if ActiveRecord::Base.connection_config[:adapter] == "postgresql"
      raise ActiveRecord::IrreversibleMigration.new
    else
      change_column :direct_messages, :receiver_id, :string
    end
  end
end
