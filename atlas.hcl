env "local" {
  url = "postgres://postgres@localhost:5433/postgres?search_path=public&sslmode=disable"
  dev = "docker://postgres/16/dev?search_path=public&sslmode=disable"
  src = "file://schema.sql"
  migration {
    dir = "file://migrations"
  }
  exclude = [
    "atlas_schema_revisions",
  ]
}
