import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _userId;
  Map<String, dynamic>? _user;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get userId => _userId;
  Map<String, dynamic>? get user => _user;
  String? get errorMessage => _errorMessage;

  final ApiService _apiService = ApiService.instance;
  final DatabaseService _dbService = DatabaseService.instance;

  // Check if user is already logged in
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _apiService.getToken();
      final userId = await _apiService.getUserId();

      if (token != null && userId != null) {
        _userId = userId;
        _isAuthenticated = true;
        
        // Load user from local database
        final userData = await _dbService.getUser(userId);
        if (userData != null) {
          _user = userData;
        }
      }
    } catch (e) {
      _errorMessage = 'Failed to check auth status';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Register new user
  Future<bool> register({
    required String email,
    required String password,
    required String name,
    String? noHp,
    String? jurusan,
    int? semester,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // For demo purposes, we'll use local storage
      // In production, uncomment the API call below
      
      // PRODUCTION CODE (with real API):
      /*
      final response = await _apiService.register(
        email: email,
        password: password,
        name: name,
        noHp: noHp,
        jurusan: jurusan,
        semester: semester,
      );

      if (response.isSuccess && response.data != null) {
        final userData = response.data!['user'];
        _userId = userData['id'];
        _user = userData;
        _isAuthenticated = true;

        // Save to local database
        await _dbService.insertUser({
          'id': userData['id'],
          'email': userData['email'],
          'name': userData['name'],
          'noHp': userData['noHp'],
          'jurusan': userData['jurusan'],
          'semester': userData['semester'],
          'photoUrl': userData['photoUrl'],
          'createdAt': DateTime.now().millisecondsSinceEpoch,
        });

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.error ?? 'Registration failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      */

      // DEMO CODE (local only):
      final userId = DateTime.now().millisecondsSinceEpoch.toString();
      final userData = {
        'id': userId,
        'email': email,
        'name': name,
        'noHp': noHp,
        'jurusan': jurusan,
        'semester': semester,
        'photoUrl': null,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      };

      await _dbService.insertUser(userData);
      await _apiService.saveUserId(userId);
      await _apiService.saveToken('demo_token_$userId');

      _userId = userId;
      _user = userData;
      _isAuthenticated = true;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Registration failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Login user
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // For demo purposes, we'll use local storage
      // In production, uncomment the API call below

      // PRODUCTION CODE (with real API):
      /*
      final response = await _apiService.login(
        email: email,
        password: password,
      );

      if (response.isSuccess && response.data != null) {
        final userData = response.data!['user'];
        _userId = userData['id'];
        _user = userData;
        _isAuthenticated = true;

        // Update local database
        final existingUser = await _dbService.getUser(userData['id']);
        if (existingUser != null) {
          await _dbService.updateUser(userData['id'], userData);
        } else {
          await _dbService.insertUser({
            ...userData,
            'createdAt': DateTime.now().millisecondsSinceEpoch,
          });
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.error ?? 'Login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      */

      // DEMO CODE (local only):
      // Simulate login by checking if user exists in local database
      // In real app, this would validate against backend
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

      final userId = 'demo_user_123'; // Fixed demo user ID
      final userData = {
        'id': userId,
        'email': email,
        'name': 'Demo User',
        'noHp': null,
        'jurusan': null,
        'semester': null,
        'photoUrl': null,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      };

      // Check if user exists, if not create it
      final existingUser = await _dbService.getUser(userId);
      if (existingUser == null) {
        await _dbService.insertUser(userData);
      }

      await _apiService.saveUserId(userId);
      await _apiService.saveToken('demo_token_$userId');

      _userId = userId;
      _user = existingUser ?? userData;
      _isAuthenticated = true;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Login failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout user
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      // PRODUCTION CODE:
      // await _apiService.logout();

      // Clear local data
      await _apiService.clearToken();
      
      _userId = null;
      _user = null;
      _isAuthenticated = false;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Logout failed: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Update user profile
  Future<bool> updateProfile({
    String? name,
    String? noHp,
    String? jurusan,
    int? semester,
    String? photoUrl,
  }) async {
    if (_userId == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // PRODUCTION CODE:
      /*
      final response = await _apiService.updateProfile(
        name: name,
        noHp: noHp,
        jurusan: jurusan,
        semester: semester,
        photoUrl: photoUrl,
      );

      if (response.isSuccess && response.data != null) {
        _user = response.data!['user'];
        await _dbService.updateUser(_userId!, _user!);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      */

      // DEMO CODE:
      final updatedUser = {
        ..._user!,
        if (name != null) 'name': name,
        if (noHp != null) 'noHp': noHp,
        if (jurusan != null) 'jurusan': jurusan,
        if (semester != null) 'semester': semester,
        if (photoUrl != null) 'photoUrl': photoUrl,
      };

      await _dbService.updateUser(_userId!, updatedUser);
      _user = updatedUser;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Update profile failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}