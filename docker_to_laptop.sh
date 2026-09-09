

#!/bin/bash

# 1. Define your destination locations as functions
jump_to_location_backup() {
    echo "Backing up project..."
    # Copy container
    docker save -o luckyweb_image.tar himilou/luckyweb:dev1
    echo "Docker image saved to luckyweb_image.tar"

    docker run --rm -v lucky_rails_storage:/volume -v .:/backup alpine tar -czf /backup/lucky_rails_storage_backup.tar.gz -C /volume .
    echo "Rails storage backup created at lucky_rails_storage_backup.tar.gz"

    docker run --rm -v lucky_rails_public_assets:/volume -v .:/backup alpine tar -czf /backup/lucky_rails_public_assets_backup.tar.gz -C /volume .
    echo "Rails public assets backup created at lucky_rails_public_assets_backup.tar.gz"

    # docker run --rm -v lucky_gem_cache:/volume -v .:/backup alpine tar -czf /backup/lucky_gem_cache_backup.tar.gz -C /volume .
    # echo "Rails gem cache backup created at lucky_gem_cache_backup.tar.gz"
    return 0
}

jump_to_location_restore() {
    echo "Successfully jumped to restore."
    docker load -i luckyweb_image.tar
    echo "Docker image loaded from luckyweb_image.tar"

    docker volume create lucky_rails_storage
    docker run --rm -v lucky_rails_storage:/volume -v .:/backup alpine tar -xzf /backup/lucky_rails_storage_backup.tar.gz -C /volume
    echo "Rails storage restored from rails_storage_backup.tar.gz"

    docker volume create lucky_rails_public_assets
    docker run --rm -v lucky_rails_public_assets:/volume -v .:/backup alpine tar -xzf /backup/lucky_rails_public_assets_backup.tar.gz -C /volume
    echo "Rails public assets restored from rails_public_assets_backup.tar.gz"

    # docker volume create lucky_gem_cache
    # docker run --rm -v lucky_gem_cache:/volume -v .:/backup alpine tar -xzf /backup/lucky_gem_cache_backup.tar.gz -C /volume
    # echo "Rails gem cache restored from lucky_gem_cache_backup.tar.gz"
    return 0
}

# 2. Check the first parameter ($1) passed to the script
case "$1" in
    "backup")
        jump_to_location_backup
        ;;
    "restore")
        jump_to_location_restore
        ;;
    *)
        echo "Error: Invalid parameter. Usage: $0 [backup|restore]"
        return 0
        ;;
esac