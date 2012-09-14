class CreateOpenIds < ActiveRecord::Migration
  def change
    create_table :open_ids do |t|
      t.belongs_to :account, :open_id_provider
      t.string :identifier, null: false
      t.timestamps
    end
  end
end
