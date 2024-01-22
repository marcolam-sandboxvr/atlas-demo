# Atlas Demo

Detailed documentation: https://atlasgo.io/

## Setup

1. Install Atlas (check [here](https://atlasgo.io/community-edition) for other installation methods)

    ```bash
    curl -sSf https://atlasgo.sh | sh -s -- --community
    ```

2. Create a PostgreSQL test database

    ```bash
    docker-compose up -d
    ```

3. Use any tool to connect to the database
   - Address: `localhost`
   - Port: `5433`
   - Database: `postgres`
   - Username: `postgres`
   - Password: no

4. Check `atlas.hcl` file for project configs (refer to [here](https://atlasgo.io/atlas-schema/projects#environments) for docs)

## Generate schema file from existing database

1. Create table in database

    ```bash
    docker exec atlas-demo-db-1 psql -h localhost -p 5432 -U postgres -d postgres -c 'CREATE TABLE users (id UUID PRIMARY KEY, name TEXT);'
    ```

2. Generate `schema.sql`

    ```bash
    atlas schema inspect --env local --format '{{ sql . }}' > schema.sql
    ```

## Declarative schema migration

1. Open `schema.sql`, change column `name` to `full_name`

    ```sql
    -- schema.sql
    -- Create "users" table
    CREATE TABLE "users" ("id" uuid NOT NULL, "full_name" text NULL, PRIMARY KEY ("id"));
    ```

2. Check the planned changes and apply schema

    ```bash
    atlas schema apply --env local
    ```

3. Clean database

    ```bash
    docker exec atlas-demo-db-1 psql -h localhost -p 5432 -U postgres -d postgres -c 'DROP TABLE users; DROP TABLE atlas_schema_revisions;'
    ```

## Versioned schema migration

1. Diff `schema.sql` with existing migrations

    ```bash
    atlas migrate diff --env local
    ```

2. Check the generated migration `.sql` files in `./migrations`

    ```sql
    -- ./migrations/<TIMESTAMP>.sql
    -- Create "users" table
    CREATE TABLE "users" ("id" uuid NOT NULL, "full_name" text NULL, PRIMARY KEY ("id"));
    ```

3. Apply the migration

    ```bash
    atlas migrate apply --env local
    ```

## Create migration manually for initial data load

1. Create an empty migration file

    ```bash
    atlas migrate new --env local
    ```

2. Add SQL to the migration file

    ```sql
    -- ./migrations/<TIMESTAMP>.sql
    -- insert "users" data
    INSERT INTO
        users (id, full_name)
    VALUES
        (
            '15ef6884-7919-4d04-869b-ba2c6f1d5a9c',
            'Test User'
        );
    ```

3. Generate hash to `atlas.sum`

    ```bash
    atlas migrate hash --env local
    ```

4. Apply the migration

    ```bash
    atlas migrate apply --env local
    ```

## Linting

1. Remove column from `schema.sql`

    ```sql
    -- schema.sql
    -- Create "users" table
    CREATE TABLE "users" ("id" uuid NOT NULL, PRIMARY KEY ("id"));
    ```

2. Generate migration

    ```bash
    atlas migrate diff --env local
    ```

3. Lint. A destructive change should be detected

    ```bash
    atlas migrate lint --env local --latest 1
    ```

## Clean up

1. Remove test database

    ```bash
    docker-compose down
    ```
