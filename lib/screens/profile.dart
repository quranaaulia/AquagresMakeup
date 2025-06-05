import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with TickerProviderStateMixin {
  String? currentUsername;
  String? currentEmail;
  bool isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadUserData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Debug: Print semua keys yang tersimpan
      print('All SharedPreferences keys: ${prefs.getKeys()}');
      
      final username = prefs.getString('current_user');
      print('Current user from SharedPreferences: $username');
      
      if (username != null && username.isNotEmpty) {
        final email = prefs.getString('email_$username');
        print('Email for $username: $email');
        
        setState(() {
          currentUsername = username;
          currentEmail = email;
          isLoading = false;
        });
        _animationController.forward();
      } else {
        print('No current user found');
        setState(() {
          currentUsername = null;
          currentEmail = null;
          isLoading = false;
        });
        _animationController.forward();
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        isLoading = false;
      });
      _animationController.forward();
    }
  }

  // Method untuk refresh data
  Future<void> _refreshUserData() async {
    setState(() {
      isLoading = true;
    });
    _animationController.reset();
    await _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8F9FF), // Putih kebiruan
              Color(0xFFE8E9FF), // Lavender terang
              Color(0xFFDDD6FE), // Ungu pastel
              Color(0xFFE0F2FE), // Biru pastel
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _refreshUserData,
            color: Color(0xFF8B5CF6),
            backgroundColor: Colors.white,
            child: isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF8B5CF6).withOpacity(0.2),
                                blurRadius: 20,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF8B5CF6),
                            ),
                            strokeWidth: 3,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Loading your profile...',
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : FadeTransition(
                    opacity: _fadeAnimation,
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            child: Column(
                              children: [
                                // Header dengan floating effect
                                _buildFloatingHeader(),
                                SizedBox(height: 20),
                                
                                // User Profile Card atau No User Card
                                if (currentUsername != null && currentUsername!.isNotEmpty) 
                                  _userProfileCard()
                                else 
                                  _noUserCard(),
                                
                                SizedBox(height: 18),
                                
                                SizedBox(height: 12),
                                
                                // Action Buttons
                                _buildActionButtons(),
                                
                                SizedBox(height: 30),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.95),
            Colors.white.withOpacity(0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF8B5CF6).withOpacity(0.15),
            blurRadius: 30,
            offset: Offset(0, 15),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            offset: Offset(-5, -5),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)],
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              Icons.person_outline_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Profile',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'Manage your account',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _userProfileCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.95),
            Colors.white.withOpacity(0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF8B5CF6).withOpacity(0.15),
            blurRadius: 30,
            offset: Offset(0, 15),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            offset: Offset(-10, -10),
            blurRadius: 20,
          ),
        ],
      ),
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          // Avatar dengan gradient border
          Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF8B5CF6),
                  Color(0xFF3B82F6),
                  Color(0xFF06B6D4),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF8B5CF6),
                      Color(0xFF3B82F6),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_rounded,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          
          SizedBox(height: 24),
          
          // Username dengan glassmorphism effect
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF8B5CF6).withOpacity(0.1),
                  Color(0xFF3B82F6).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Color(0xFF8B5CF6).withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.account_circle_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  currentUsername!,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 16),
          
          // Email
          if (currentEmail != null && currentEmail!.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF06B6D4).withOpacity(0.1),
                    Color(0xFF3B82F6).withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Color(0xFF06B6D4).withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.email_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  SizedBox(width: 12),
                  Flexible(
                    child:                     Text(
                      currentEmail!,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF374151),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          
          SizedBox(height: 24),
          
          // Welcome Message dengan modern design
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF3E8FF),
                  Color(0xFFEFF6FF),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Color(0xFF8B5CF6).withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Welcome to Beauty Universe!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF581C87),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'AquagresMakeup ',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _noUserCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.95),
            Colors.white.withOpacity(0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF8B5CF6).withOpacity(0.15),
            blurRadius: 30,
            offset: Offset(0, 15),
          ),
        ],
      ),
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF8B5CF6).withOpacity(0.1),
                  Color(0xFF3B82F6).withOpacity(0.1),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_add_outlined,
              size: 48,
              color: Color(0xFF8B5CF6),
            ),
          ),
          SizedBox(height: 18),
          Text(
            'Welcome!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Please login or register to access your profile',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF8B5CF6).withOpacity(0.3),
                  blurRadius: 15,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(Icons.favorite_rounded, color: Colors.white, size: 24),
                SizedBox(height: 8),
                Text(
                  'Favorites',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '12',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF06B6D4).withOpacity(0.3),
                  blurRadius: 15,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(Icons.shopping_bag_rounded, color: Colors.white, size: 24),
                SizedBox(height: 8),
                Text(
                  'Orders',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '8',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Refresh Button
        Container(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _refreshUserData,
            icon: Icon(Icons.refresh_rounded, size: 20),
            label: Text(
              'Refresh Profile',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Color(0xFF8B5CF6),
              elevation: 0,
                                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: Color(0xFF8B5CF6).withOpacity(0.2),
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
        
        if (currentUsername == null || currentUsername!.isEmpty) ...[
          SizedBox(height: 12),
          Container(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // Navigate to login page
              },
              icon: Icon(Icons.login_rounded, size: 20),
              label: Text(
                'Login Now',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
                elevation: 8,
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                shadowColor: Color(0xFF8B5CF6).withOpacity(0.4),
              ),
            ),
          ),
        ],
      ],
    );
  }
}