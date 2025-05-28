import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'job_list_page.dart'; // 채용공고 리스트 페이지 import 필요


class HomeScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const HomeScreen({Key? key, required this.onLogout}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoggedIn = false;
  bool isLoading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  // 로그인 상태 확인
  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (!mounted) return;
    setState(() {
      isLoggedIn = token != null;
      isLoading = false;
    });

    if (!isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen(onLogin: _handleLogin)),
        );
      });
    }
  }

  // 로그인 후 처리 콜백
  void _handleLogin() {
    if (!mounted) return;
    setState(() {
      isLoggedIn = true;
    });
  }

  // 로그아웃 함수
  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('email');
    await prefs.remove('name');

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => LoginScreen(onLogin: _handleLogin)),
          (route) => false,
    );
  }

  // 하단 탭 변경 처리
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // 페이지 리스트
  List<Widget> get _pages => [
    _buildHomePage(),
    Center(child: Text('Search')),
    JobListPage(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Job Platform Home'),
        actions: [
          if (isLoggedIn)
            TextButton(
              onPressed: _logout,
              child: Text('로그아웃', style: TextStyle(color: Colors.black)),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey[500],
        backgroundColor: Colors.black,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      body: SafeArea(
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : _pages[_selectedIndex],
      ),
    );
  }

  // 홈 콘텐츠
  Widget _buildHomePage() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.all(16),
            children: [
              // Search bar
              TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _roundedButton(Icons.favorite_border, 'Favorites'),
                  _roundedButton(Icons.history, 'History'),
                  _roundedButton(Icons.person_add_alt, 'Following'),
                  _roundedButton(Icons.receipt_long, 'Orders'),
                ],
              ),
              SizedBox(height: 16),

              // Banner
              Container(
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: AssetImage('assets/banner.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('Banner title', style: TextStyle(color: Colors.white, fontSize: 20)),
                  ),
                ),
              ),
              SizedBox(height: 24),

              // Category title
              _sectionTitle('Title'),
              SizedBox(
                height: 80,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: List.generate(5, (index) => _circleCategory('Title')),
                ),
              ),
              SizedBox(height: 24),

              // Product title
              _sectionTitle('Title'),
              GridView.count(
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                childAspectRatio: 0.7,
                children: List.generate(6, (index) => _productCard()),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _roundedButton(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: Colors.grey[200],
          child: Icon(icon, color: Colors.black),
        ),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Icon(Icons.arrow_forward_ios, size: 16),
      ],
    );
  }

  Widget _circleCategory(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: AssetImage('assets/sample.jpg'),
          ),
          SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _productCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: AssetImage('assets/product.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        SizedBox(height: 8),
        Text('Brand', style: TextStyle(color: Colors.grey, fontSize: 12)),
        Text('Product name', style: TextStyle(fontWeight: FontWeight.bold)),
        Text('\$10.99'),
      ],
    );
  }
}
