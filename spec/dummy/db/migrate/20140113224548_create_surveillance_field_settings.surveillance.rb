# This migration comes from surveillance (originally 20130710151627)
class CreateSurveillanceFieldSettings < ActiveRecord::Migration
  def change
    create_table :surveillance_field_settings do |t|
      t.string :key
      t.text :value
      t.integer :question_id

      t.timestamps
    end
  end
end
