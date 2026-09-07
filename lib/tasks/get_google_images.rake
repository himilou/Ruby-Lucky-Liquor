




# lib/tasks/workflow.rake
namespace :images do
  desc "Download new images from google drive and jsonify"
  task run_all: :environment do
    # Define tasks in sequence
    tasks = [
      "images:sync_from_google_drive",
      "images:parse_to_json"
    ]

    tasks.each do |task_name|
      puts "=== Starting: #{task_name} ==="
      Rake::Task[task_name].invoke
      puts "=== Finished: #{task_name} ===\n\n"
    end
  end

  # following is just sample code for task creation
  desc "Backup database data"
  task backup_data: :environment do
    puts "Backing up database..."
    # Example: User.count tracking or backup logic here
  end

  desc "Clear application cache"
  task clear_cache: :environment do
    puts "Clearing Rails cache..."
    Rails.cache.clear
  end
end
