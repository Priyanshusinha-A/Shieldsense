import 'package:mongo_dart/mongo_dart.dart';
import '../models/user.dart';

class DatabaseService {
  static const String _username = 'shieldsense7_db_user';
  static const String _rawPassword = '9pf29i6CAjedgwOT'; // or your latest one
  static final String _password = Uri.encodeComponent(_rawPassword);
  static final String _connectionString =
       "mongodb+srv://shieldsense7_db_user:9pf29i6CAjedgwOT@shieldsense.kmzq1ug.mongodb.net/shieldsense?authSource=admin&retryWrites=true&w=majority";
  static const String _databaseName = 'shieldsense';
  static const String _collectionName = 'users';



  static Db? _db;
  static DbCollection? _usersCollection;

  static Future<void> connect() async {
    try {
      _db = await Db.create(_connectionString);
      await _db!.open();
      _usersCollection = _db!.collection(_collectionName); 
      print('Connected to MongoDB');
    } catch (e) {
      print('Failed to connect to MongoDB: $e');
      throw e;
    }
  }

  static Future<void> disconnect() async {
    if (_db != null) {
      await _db!.close();
      print('Disconnected from MongoDB');
    }
  }

  static Future<bool> signup(User user) async {
    try {
      if (_db == null || !_db!.isConnected) {
        await connect();
      }

      // Check if user already exists
      final existingUser = await _usersCollection!.findOne(
        where.raw({
          '\$or': [
            {'username': user.username},
            {'email': user.email}
          ]
        })
      );

      if (existingUser != null) {
        print('User already exists with username: ${user.username} or email: ${user.email}');
        return false; // User already exists
      }

      // Insert new user
      final result = await _usersCollection!.insertOne(user.toJson());
      print('User signup successful for: ${user.email}, insert result: $result');
      return true;
    } catch (e) {
      print('Signup error: $e');
      return false;
    }
  }
  static bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static Future<User?> login(String usernameOrEmail, String password) async {
    try {
      if (_db == null || !_db!.isConnected) {
        await connect();
      }

      User? user;

      if (_isValidEmail(usernameOrEmail)) {
        // Check only email
        final userDoc = await _usersCollection!.findOne(
          where.eq('email', usernameOrEmail).and(where.eq('password', password))
        );
        if (userDoc != null) {
          user = User.fromJson(userDoc);
        }
      } else {
        // Check only username
        final userDoc = await _usersCollection!.findOne(
          where.eq('username', usernameOrEmail).and(where.eq('password', password))
        );
        if (userDoc != null) {
          user = User.fromJson(userDoc);
        }
      }

      if (user != null) {
        print('Login successful for user: $usernameOrEmail');
        return user;
      }

      print('Login failed: Invalid credentials for: $usernameOrEmail');
      return null;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  static Future<void> updateUser(User user) async {
    try {
      if (_usersCollection == null) await connect();

      await _usersCollection!.replaceOne(
        where.eq('id', user.id),
        user.toJson()
      );
    } catch (e) {
      print('Update user error: $e');
    }
  }

  static Future<List<User>> getAllUsers() async {
    try {
      if (_usersCollection == null) await connect();

      final users = await _usersCollection!.find().toList();
      return users.map((doc) => User.fromJson(doc)).toList();
    } catch (e) {
      print('Get all users error: $e');
      return [];
    }
  }

  static Future<void> clearAllUsers() async {
    try {
      if (_usersCollection == null) await connect();

      await _usersCollection!.deleteMany({});
      print('All users deleted from database');
    } catch (e) {
      print('Clear all users error: $e');
    }
  }

  static Future<User?> getUserByEmail(String email) async {
    try {
      if (_usersCollection == null) await connect();

      final userDoc = await _usersCollection!.findOne(where.eq('email', email));
      if (userDoc != null) {
        return User.fromJson(userDoc);
      }
      return null;
    } catch (e) {
      print('Get user by email error: $e');
      return null;
    }
  }
}
