import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:papela/models/user.dart';
import 'package:papela/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.role == UserRole.admin;
  bool get isCustomer => _currentUser?.role == UserRole.customer;

  AuthProvider() {
    _initAuth();
  }

  void _initAuth() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null) {
        await _loadUserData(user.uid);
      } else {
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  Future<void> _loadUserData(String uid) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        _currentUser = UserModel.fromFirestore(userDoc);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Error loading user data: $e';
      notifyListeners();
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    debugPrint(error);
    notifyListeners();
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    UserRole role = UserRole.customer,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      // Validate password strength (NFR-SEC-01)
      if (!_isPasswordStrong(password)) {
        _setError(
          'Password must be at least 12 characters with uppercase, lowercase, digits, and symbols',
        );
        _setLoading(false);
        return false;
      }

      UserCredential result = await _authService.signUp(email, password);

      if (result.user != null) {
        // Create user document in Firestore
        UserModel newUser = UserModel(
          id: result.user!.uid,
          email: email,
          name: name,
          phone: phone,
          role: role,
          createdAt: DateTime.now(),
        );

        await _firestore.collection('users').doc(result.user!.uid).set(newUser.toFirestore());
        _currentUser = newUser;
        _setLoading(false);
        return true;
      }
    } catch (e) {
      _setError(_getErrorMessage(e));
    }
    _setLoading(false);
    return false;
  }

  Future<bool> signIn({required String email, required String password}) async {
    try {
      _setLoading(true);
      _setError(null);

      UserCredential result = await _authService.signIn(email, password);

      if (result.user != null) {
        await _loadUserData(result.user!.uid);
        _setLoading(false);
        return true;
      }
    } catch (e) {
      _setError(_getErrorMessage(e));
    }
    _setLoading(false);
    return false;
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      _setError('Error signing out: $e');
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _setError(null);

      await _authService.resetPassword(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setLoading(false);
      return false;
    }
  }

  bool _isPasswordStrong(String password) {
    // NFR-SEC-01: Minimum 12 characters with uppercase, lowercase, digits, and symbols
    if (password.length < 12) return false;

    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    bool hasDigits = password.contains(RegExp(r'[0-9]'));
    bool hasSymbols = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    return hasUppercase && hasLowercase && hasDigits && hasSymbols;
  }

  String _getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No user found with this email address.';
        case 'wrong-password':
          return 'Incorrect password.';
        case 'email-already-in-use':
          return 'An account already exists with this email address.';
        case 'weak-password':
          return 'Password is too weak.';
        case 'invalid-email':
          return 'Invalid email address.';
        default:
          return error.message ?? 'An authentication error occurred.';
      }
    }
    return error.toString();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
