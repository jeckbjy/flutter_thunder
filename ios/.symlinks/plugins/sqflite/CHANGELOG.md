## 1.1.1

* Use mixin and extract non flutter code into `sqlite_api.dart`
* Deprecate `SqfliteOptions` which is only used internally

## 1.1.0

* **Breaking change**. Migrate from the deprecated original Android Support
    Library to AndroidX. This shouldn't result in any functional changes, but it
    requires any Android apps using this plugin to [also
    migrate](https://developer.android.com/jetpack/androidx/migrate) if they're
    using the original support library.
    
    You might say thay version should be bumped to 2.0.0, however it is just a tooling issue, code is not changed.
    This is a copy of the changes made in the flutter plugins

## 1.0.0

* Upgrade 0.13.0 version as 1.0.0
* Remove deprecated API (applyBatch, apply)

## 0.13.0

* Add support for `continueOrError` for batches

## 0.12.0

* iOS objective C prefix added to prevent conflict
* on iOS create the directory of the database if it does not exist

## 0.11.2

* add `Database.isOpen` which becomes false once the database is closed

## 0.11.1

* add `Sqlflite.hex` to allow querying on blob fields

## 0.11.0

* add `getDatabasesPath` to use as the base location to create a database
* Warning: database are now single instance by default (based on `path`), to use the
  old behavior use `singleInstance = false` when opening a database
* dart2 stable support

## 0.10.0

* Preparing for 1.0
* Remove deprecated methods (re-entrant transactions)
* Add `Transaction.batch`
* Show developer warning to prevent deadlock

## 0.9.0

* Support for in-memory database (`:memory:` path)
* Support for single instance
* new database factory for handling the new options

## 0.8.9

* Upgrade to sdk 27

## 0.8.8

* Allow testing for constraint exception

## 0.8.6

* better sql error report
* catch android native errors
* no longer print an error when deleting a database fails

## 0.8.4

* Add read-only support using `openReadOnlyDatabase`

## 0.8.3

* Allow running a batch during a transaction using `Transaction.applyBatch`
* Restore `Batch.commit` to use outside a transaction

## 0.8.2

* Although already in a transaction, allow creating nested transactions during open

## 0.8.1

* New `Transaction` mechanism not using Zone (old one still supported for now)
* Start using `Batch.apply` instead of `Batch.commit`
* Deprecate `Database.inTransaction` and `Database.synchronized` so that Zones are not used anymore

## 0.7.1

* add `Batch.query`, `Batch.rawQuery` and `Batch.execute`
* pack query result as colums/rows instead of List<Map>

## 0.7.0

* Add support for `--preview-dart-2`

## 0.6.2+1

* Add longer description to pubspec.yaml

## 0.6.2

* Fix travis warning

## 0.6.1

* Add Flutter SDK constraint to pubspec.yaml

## 0.6.0

* add support for `onConfigure` to allow for database configuration

## 0.5.0

* Escape table and column name when needed in insert/update/query/delete
* Export ConflictAlgorithm, escapeName, unescapeName in new sql.dart

## 0.4.0

* Add support for Batch (insert/update/delete)

## 0.3.1

* Remove temp concurrency experiment

## 0.3.0

2018/01/04

* **Breaking change**. Upgraded to Gradle 4.1 and Android Studio Gradle plugin
  3.0.1. Older Flutter projects need to upgrade their Gradle setup as well in
  order to use this version of the plugin. Instructions can be found
  [here](https://github.com/flutter/flutter/wiki/Updating-Flutter-projects-to-Gradle-4.1-and-Android-Studio-Gradle-plugin-3.0.1).

## 0.2.4

* Dependency on synchronized updated to >=1.1.0

## 0.2.3

* Make Android sends the reponse in the same thread then the caller to prevent unexpected behavior when an error occured

## 0.2.2

* Fix unchecked warning on Android

## 0.2.0

* Use NSOperationQueue for all db operation on iOS
* Use ThreadHandler for all db operation on Android

## 0.0.3

* Add exception handling

## 0.0.2

* Add sqlite helpers based on Razvan Lung suggestions

## 0.0.1

* Initial experimentation
