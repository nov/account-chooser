class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string :email, :name, null: false
      t.string :photo
      t.string :password_digest, :identifier
      t.timestamps
    end
    add_index :accounts, :email, unique: true
    add_index :accounts, :identifier, unique: true, alllow_nil: true
  end
end
