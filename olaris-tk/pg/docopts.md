# Plugin ops a41 pg

AI tasks to manage Postgresql

## Synopsis

```text
Usage:
  pg cli [<command>]
  pg lite2pg <file>
  pg export <schema> <file>
  pg sqload <filesql> [--group=<count>]
  pg sql [<sql>]
```

Note you have:
- *TEST* commands affecting the test database (pointed by tests/.env)
- *PROD* commands affecting the production database 

Local (test) commands:
- `cli` opens a CLI to the *TEST* database
- `lite2pg` imports a sqlite file in the *TEST*
- `export` exports a database from the *TEST* 
- `sqload` execute a sql file against the *PROD* - you can group `<count>` statements 
- `sql` execute a single statements against the *PROD*