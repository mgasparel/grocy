# Custom Docker image with mounted code

This setup builds a Grocy runtime image without bundling application code, and mounts the repo as a volume at runtime. Data is persisted in a separate volume.

## Build & run (compose)

From the repo root:

- Build and start
  - `docker compose -f docker/docker-compose.yml up -d --build`

- Stop
  - `docker compose -f docker/docker-compose.yml down`

## Volumes & paths

- Code (bind mount): `../` -> `/app/www`
- Data (named volume): `grocy-config` -> `/config`
- App data path: `/config/data` (via `GROCY_DATAPATH`)

On first start, `config-dist.php` is copied to `/config/data/config.php` if it does not exist.

## Update flow

1. `git pull` (your custom branch)
2. `docker compose -f docker/docker-compose.yml up -d --build`
3. Visit the root route `/` to run database migrations if needed

## Database migrations in this image

- Grocy still runs its normal migrations on the root route (`/`).
- The entrypoint additionally bootstraps SQL migrations when the database is empty
  (i.e. new volume or after a reset) to avoid missing-core-table errors.
- This uses the `sqlite` CLI installed in the image.

If you don’t want the bootstrap behavior, remove the SQL bootstrap block from
[docker/entrypoint.sh](docker/entrypoint.sh) and the `sqlite` package from
[docker/Dockerfile](docker/Dockerfile).

## Notes

- Ensure the bind-mounted code path is readable by the container.
- Ensure the `/config` volume is writable so the app can store database and cache files.
