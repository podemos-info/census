# frozen_string_literal: true

namespace :encryption do
  CONFIG_FILE = "symmetric-encryption.yml"

  task :remove do
    set :confirmed, proc {
      puts <<-WARN

      ========================================================================
            WARNING: You're about to delete the encryption information,
            stored encrypted data will not be recoverable after this.
      ========================================================================

      WARN
      ask :answer, "Are you sure you want to continue? Type 'remove'"
      fetch(:answer) == "remove"
    }.call

    unless fetch(:confirmed)
      puts "\nI'm pleased that I asked!"
      exit
    end

    on roles(:master, :slave) do
      within current_path do
        config_path = shared_path.join(CONFIG_FILE)
        keys_path = shared_path.join("config", "keys")
        keys_files = shared_path.join("config", "keys", "*")

        execute :rm, "-f", release_path.join("config", CONFIG_FILE)
        execute :rm, "-f", config_path

        execute :chmod, "-R", "0777", keys_path
        execute :rm, "-f", keys_files
        execute :chmod, "0500", keys_path
      end
    end
  end

  task :symlink do
    on roles(:app) do
      within current_path do
        source_path = shared_path.join(CONFIG_FILE)
        target_path = release_path.join("config", CONFIG_FILE)
        if test("[ -f #{source_path} ] && [ ! -f #{target_path} ]")
          execute :ln, "-s", source_path, target_path
        end
      end
    end
  end

  task :setup do
    on roles(:master) do
      within current_path do
        config_path = shared_path.join(CONFIG_FILE)
        keys_path = shared_path.join("config", "keys")
        keys_files = shared_path.join("config", "keys", "*")

        execute :chmod, "0777", keys_path
        execute :bundle, :exec, "symmetric-encryption", "--generate", "--app-name census", "--environments production",
                "--config", config_path, "--key-path", keys_path

        download! config_path.to_s, "tmp/"
        download! keys_path.to_s, "tmp/", recursive: true

        execute :chmod, "-R", "0400", keys_files
        execute :chmod, "0500", keys_path
      end
    end

    on roles(:slave) do
      within current_path do
        config_path = shared_path.join(CONFIG_FILE)
        keys_path = shared_path.join("config", "keys")
        keys_files = shared_path.join("config", "keys", "*")

        execute :chmod, "0777", keys_path
        upload! "tmp/#{CONFIG_FILE}", config_path.to_s
        upload! "tmp/keys", shared_path.join("config").to_s, recursive: true

        execute :chmod, "-R", "0400", keys_files
        execute :chmod, "0500", keys_path
      end
    end

    run_locally do
      execute :rm, "tmp/#{CONFIG_FILE}"
      execute :rm, "-r", "tmp/keys"
    end

    invoke "encryption:symlink"
  end
end
