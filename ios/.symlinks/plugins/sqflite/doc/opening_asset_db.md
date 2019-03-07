# Open an asset database

## Add the asset

* Add the asset in your file system at the root of your project. Typically 
I would create an `assets` folder and put my file in it:
````
assets/examples.db
````

* Specify the asset(s) in your `pubspec.yaml` in the flutter section
````
flutter:
  assets:
    - assets/example.db
````

## Copy the database to your file system

Whether you want a fresh copy from the asset or always copy the asset is up to
you and depends on your usage
* are you modifying the asset database
* do you always want a fresh copy from the asset
* do you want to optimize for performance and size


### Optimizing for performance

For better performance you should copy the asset only once (the first time) then
always try to open the copy

```dart
var databasesPath = await getDatabasesPath();
var path = join(databasesPath, "demo_asset_example.db");

// try opening (will work if it exists)
Database db;
try {
  db = await openDatabase(path, readOnly: true);
} catch (e) {
  print("Error $e");
}

if (db == null) {
  // Should happen only the first time you launch your application
  print("Creating new copy from asset");

  // Copy from asset
  ByteData data = await rootBundle.load(join("assets", "example.db"));
  List<int> bytes =
  data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  await new File(path).writeAsBytes(bytes);

  // open the database
  db = await openDatabase(path, readOnly: true);
} else {
  print("Opening existing database");
}

```

### Optimizing for size

Even better on iOS you could write a native plugin that get the asset file path
and directly open it in read-only mode. Android does not have such ability

### Always getting a fresh copy from the asset

```dart
var databasesPath = await getDatabasesPath();
var path = join(databasesPath, "demo_always_copy_asset_example.db");

// delete existing if any
await deleteDatabase(path);

// Copy from asset
ByteData data = await rootBundle.load(join("assets", "example.db"));
List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
await new File(path).writeAsBytes(bytes);

// open the database
var db = await openDatabase(path, readOnly: true);
```

### Custom strategy

You might want to have a versioning strategy (not yet part of this project) to only copy the asset db when
it changes in the build system or might also allow the user to modify the database (in this case you must copy it
first).

## Open it!
````
// open the database
Database db = await openDatabase(path);
````

