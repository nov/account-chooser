class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string :email, :name, null: false
      t.string :photo
      t.string :password_digest, null: false
      t.timestamps
    end
    add_index :accounts, :email, unique: true
  end
end
