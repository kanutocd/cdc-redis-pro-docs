class CreateDemoRuns < ActiveRecord::Migration[8.1]
  def change
    create_table :demo_runs do |t|
      t.string :mode, null: false
      t.string :title, null: false
      t.string :status, null: false, default: "queued"
      t.text :summary
      t.text :config_path
      t.text :command
      t.text :stdout
      t.text :stderr
      t.integer :exit_status
      t.decimal :elapsed_seconds, precision: 10, scale: 3
      t.datetime :started_at
      t.datetime :finished_at

      t.timestamps
    end

    add_index :demo_runs, :mode
    add_index :demo_runs, :status
  end
end
