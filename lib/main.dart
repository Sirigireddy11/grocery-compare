import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCe9rbKrY4fZNII7Mk4pF5jkkCeD_G0Z_w",
      authDomain: "smart-grocery-price-comparator.firebaseapp.com",
      projectId: "smart-grocery-price-comparator",
      storageBucket: "smart-grocery-price-comparator.firebasestorage.app",
      messagingSenderId: "139120870100",
      appId: "1:139120870100:android:f1a0643510d016456bf141",
    ),
  );
  runApp(const GroceryApp());
}

class GroceryApp extends StatelessWidget {
  const GroceryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Grocery Compare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) {
          return const HomeScreen();
        }
        return const LoginScreen();
      },
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLoading = false;

  Future<void> signInWithGoogle() async {
    setState(() => isLoading = true);
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: "139120870100-5vp0uv2jpen2lm27ilkm3jmjlhu8ugh1.apps.googleusercontent.com",
      );
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => isLoading = false);
        return;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign in failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade700, Colors.green.shade400],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shopping_cart, size: 100, color: Colors.white),
                const SizedBox(height: 24),
                const Text('Smart Grocery Compare',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 8),
                const Text('Find best prices near you',
                    style: TextStyle(fontSize: 16, color: Colors.white70)),
                const SizedBox(height: 60),
                isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : ElevatedButton.icon(
                        onPressed: signInWithGoogle,
                        icon: const Icon(Icons.login, color: Colors.red),
                        label: const Text('Sign in with Google',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          minimumSize: const Size(double.infinity, 55),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                const SizedBox(height: 24),
                const Text('Compare grocery prices across\nneighbourhood stores in Chennai',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

List<Map<String, dynamic>> cartItems = [];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser;

  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('🛒 Smart Grocery Compare'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: signOut,
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade700, Colors.green.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hello, ${user?.displayName?.split(' ').first ?? 'User'}! 👋',
                      style: const TextStyle(fontSize: 18, color: Colors.white70)),
                  const SizedBox(height: 4),
                  const Text('Find Best Grocery Prices',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 6),
                  const Text('Compare prices across neighbourhood stores in Chennai',
                      style: TextStyle(fontSize: 14, color: Colors.white70)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
                    child: const Row(
                      children: [
                        Icon(Icons.search, color: Colors.grey),
                        SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search grocery items...',
                              border: InputBorder.none,
                              hintStyle: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CompareScreen())),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: Colors.green.shade600, borderRadius: BorderRadius.circular(16)),
                        child: const Column(children: [
                          Icon(Icons.compare_arrows, color: Colors.white, size: 36),
                          SizedBox(height: 8),
                          Text('Compare\nPrices', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ]),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen())),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: Colors.orange.shade600, borderRadius: BorderRadius.circular(16)),
                        child: const Column(children: [
                          Icon(Icons.shopping_cart, color: Colors.white, size: 36),
                          SizedBox(height: 8),
                          Text('My\nCart', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ]),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MapScreen())),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: Colors.blue.shade600, borderRadius: BorderRadius.circular(16)),
                        child: const Column(children: [
                          Icon(Icons.store, color: Colors.white, size: 36),
                          SizedBox(height: 8),
                          Text('Nearby\nStores', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Today\'s Best Deals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('groceries').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final items = snapshot.data!.docs;
                return SizedBox(
                  height: 130,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final data = items[index].data() as Map<String, dynamic>;
                      final balayya = (data['balayya'] ?? 0) as int;
                      final saiRam = (data['sai RAM'] ?? 0) as int;
                      final mediumBazzer = (data['medium Bazzer'] ?? 0) as int;
                      final minPrice = [balayya, saiRam, mediumBazzer].reduce((a, b) => a < b ? a : b);
                      final minStore = balayya == minPrice ? 'Balayya' : saiRam == minPrice ? 'Sai RAM' : 'Medium Bazzer';
                      return Container(
                        width: 130,
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.15), blurRadius: 8)],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(data['Name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(height: 6),
                            Text('Best: Rs.$minPrice', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('at $minStore', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                              child: const Text('View Deal', style: TextStyle(color: Colors.green, fontSize: 11)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.green, size: 30),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Your Location', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('Chennai, Tamil Nadu', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                    Text('3 stores nearby', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class CompareScreen extends StatefulWidget {
  const CompareScreen({super.key});

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compare Prices'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.green.shade50,
            child: TextField(
              onChanged: (val) => setState(() => searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search items...',
                prefixIcon: const Icon(Icons.search, color: Colors.green),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('groceries').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final items = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return (data['Name'] ?? '').toString().toLowerCase().contains(searchQuery.toLowerCase());
                }).toList();
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final data = items[index].data() as Map<String, dynamic>;
                    final balayya = (data['balayya'] ?? 0) as int;
                    final saiRam = (data['sai RAM'] ?? 0) as int;
                    final mediumBazzer = (data['medium Bazzer'] ?? 0) as int;
                    final prices = {'Balayya': balayya, 'Sai RAM': saiRam, 'Medium Bazzer': mediumBazzer};
                    final minPrice = prices.values.reduce((a, b) => a < b ? a : b);
                    final maxPrice = prices.values.reduce((a, b) => a > b ? a : b);
                    final savings = maxPrice - minPrice;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(data['Name'] ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(8)),
                                  child: Text('Save Rs.$savings', style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold, fontSize: 12)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ...prices.entries.map((e) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(children: [
                                        Icon(Icons.store, size: 16, color: e.value == minPrice ? Colors.green : Colors.grey),
                                        const SizedBox(width: 6),
                                        Text(e.key, style: const TextStyle(fontSize: 14)),
                                      ]),
                                      Row(children: [
                                        Text('Rs.${e.value}',
                                            style: TextStyle(
                                                fontSize: 15,
                                                color: e.value == minPrice ? Colors.green : Colors.black87,
                                                fontWeight: e.value == minPrice ? FontWeight.bold : FontWeight.normal)),
                                        if (e.value == minPrice)
                                          const Text('  ✓ Best', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                                      ]),
                                    ],
                                  ),
                                )),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  setState(() => cartItems.add(Map<String, dynamic>.from(data)));
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text('${data['Name']} added to cart!'),
                                    backgroundColor: Colors.green,
                                  ));
                                },
                                icon: const Icon(Icons.add_shopping_cart),
                                label: const Text('Add to Cart'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, int> storeTotals = {'Balayya': 0, 'Sai RAM': 0, 'Medium Bazzer': 0};
    for (var item in cartItems) {
      storeTotals['Balayya'] = storeTotals['Balayya']! + ((item['balayya'] ?? 0) as int);
      storeTotals['Sai RAM'] = storeTotals['Sai RAM']! + ((item['sai RAM'] ?? 0) as int);
      storeTotals['Medium Bazzer'] = storeTotals['Medium Bazzer']! + ((item['medium Bazzer'] ?? 0) as int);
    }
    final cheapest = storeTotals.entries.reduce((a, b) => a.value < b.value ? a : b).key;
    final mostExpensive = storeTotals.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    final savings = storeTotals[mostExpensive]! - storeTotals[cheapest]!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        backgroundColor: Colors.orange.shade600,
        foregroundColor: Colors.white,
      ),
      body: cartItems.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Your cart is empty!', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  SizedBox(height: 8),
                  Text('Add items from Compare Prices', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : Column(
              children: [
                if (savings > 0)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    color: Colors.green.shade50,
                    child: Row(
                      children: [
                        const Icon(Icons.savings, color: Colors.green, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text('You can save Rs.$savings by shopping at $cheapest!',
                              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          leading: const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.check, color: Colors.white)),
                          title: Text(cartItems[index]['Name'] ?? ''),
                          trailing: const Icon(Icons.drag_handle, color: Colors.grey),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -3))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Best store for your full cart:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      ...storeTotals.entries.map((e) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: e.key == cheapest ? Colors.green.shade50 : Colors.grey.shade100,
                              border: Border.all(color: e.key == cheapest ? Colors.green : Colors.grey.shade300, width: e.key == cheapest ? 2 : 1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(e.key, style: TextStyle(fontWeight: e.key == cheapest ? FontWeight.bold : FontWeight.normal, fontSize: 14)),
                                Text('Rs.${e.value}', style: TextStyle(color: e.key == cheapest ? Colors.green : Colors.black, fontWeight: FontWeight.bold, fontSize: 15)),
                                if (e.key == cheapest)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(12)),
                                    child: const Text('🏆 Best Deal', style: TextStyle(color: Colors.white, fontSize: 12)),
                                  ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stores = [
      {'name': 'Balayya', 'address': 'Anna Nagar, Chennai', 'distance': '0.5 km', 'color': Colors.green},
      {'name': 'Sai RAM', 'address': 'T Nagar, Chennai', 'distance': '1.2 km', 'color': Colors.orange},
      {'name': 'Medium Bazzer', 'address': 'Vadapalani, Chennai', 'distance': '2.1 km', 'color': Colors.blue},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Stores'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade300, Colors.blue.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on, size: 50, color: Colors.white),
                  SizedBox(height: 8),
                  Text('Chennai, Tamil Nadu',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  SizedBox(height: 4),
                  Text('3 stores found nearby', style: TextStyle(color: Colors.white70)),
                  SizedBox(height: 12),
                  Text('📍 Your location detected',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Stores Near You', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: stores.length,
              itemBuilder: (context, index) {
                final store = stores[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: store['color'] as Color,
                      child: const Icon(Icons.store, color: Colors.white),
                    ),
                    title: Text(store['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(store['address'] as String),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(store['distance'] as String,
                            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                        const Text('away', style: TextStyle(color: Colors.grey, fontSize: 11)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}