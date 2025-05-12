// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../models/birthday.dart';
import '../services/database_helper.dart';
import '../widgets/birthday_card.dart';
import '../widgets/stat_card.dart';
import '../widgets/upcoming_birthdays.dart';
import 'add_birthday_screen.dart';
import 'settings_screen.dart';
import 'edit_birthday_screen.dart'; // Ensure this file contains the EditBirthdayScreen class
import '../widgets/expandable_fab.dart';
import '../viewmodels/contact_import_viewmodel.dart';
import '../services/context_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Birthday> _birthdays = [];
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  int _selectedIndex = 0;
  bool _isSearching = false;
  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadBirthdays();
  }

  Future<void> _loadBirthdays() async {
    if (!mounted) return;
    try {
      final birthdays = await _databaseHelper.getBirthdays();
      setState(() {
        _birthdays.clear();
        _birthdays.addAll(birthdays);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load birthdays: $e')),
        );
      }
    }
  }

  List<Birthday> get _upcomingBirthdays {
    final now = DateTime.now();
    return _birthdays
        .where((b) {
          final nextBirthday = DateTime(
            now.year,
            b.birthDate.month,
            b.birthDate.day,
          );
          return nextBirthday.isAfter(now) ||
              nextBirthday.isAtSameMomentAs(DateTime(now.year, now.month, now.day));
        })
        .toList()
      ..sort((a, b) {
          final aDate = DateTime(now.year, a.birthDate.month, a.birthDate.day);
          final bDate = DateTime(now.year, b.birthDate.month, b.birthDate.day);
          return aDate.compareTo(bDate);
        });
  }

  Widget _buildDashboard() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Modern Statistics Cards with Gradient
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primaryContainer,
                        Theme.of(context).colorScheme.secondaryContainer,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Hero(
                            tag: 'total_stats',
                            child: StatCard(
                              title: 'Total',
                              value: _birthdays.length.toString(),
                              icon: Icons.people,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Hero(
                            tag: 'monthly_stats',
                            child: StatCard(
                              title: 'This Month',
                              value: _getMonthlyBirthdays(),
                              icon: Icons.calendar_today,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Animated Upcoming Birthdays
        if (_upcomingBirthdays.isNotEmpty)
          SliverAnimatedList(
            initialItemCount: _upcomingBirthdays.length,
            itemBuilder: (context, index, animation) {
              return SlideTransition(
                position: animation.drive(Tween(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                )),
                child: FadeTransition(
                  opacity: animation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: UpcomingBirthdays(birthdays: [_upcomingBirthdays[index]]),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildBirthdaysList() {
    return _birthdays.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cake_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                const Text('No birthdays added yet'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _addBirthday,
                  child: const Text('Add Birthday'),
                ),
              ],
            ),
          )
        : ListView.builder(
            itemCount: _birthdays.length,
            itemBuilder: (context, index) {
              final birthday = _birthdays[index];
              return BirthdayCard(
                birthday: birthday,
                onDelete: () => _deleteBirthday(birthday),
                onEdit: () => _editBirthday(birthday),
              );
            },
          );
  }

  String _calculateAverageAge() {
    if (_birthdays.isEmpty) return '0';
    final now = DateTime.now();
    final total = _birthdays.fold<int>(
      0,
      (sum, birthday) => sum + (now.year - birthday.birthDate.year),
    );
    return (total / _birthdays.length).toStringAsFixed(1);
  }

  String _getMonthlyBirthdays() {
    return _birthdays
        .where((b) => b.birthDate.month == DateTime.now().month)
        .length
        .toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AnimatedCrossFade(
          firstChild: const Text('Birthday Alarm'),
          secondChild: SearchBar(
            hintText: 'Search birthdays...',
            onChanged: _filterBirthdays,
            leading: const Icon(Icons.search),
          ),
          crossFadeState: _isSearching 
              ? CrossFadeState.showSecond 
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _loadBirthdays();
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SettingsScreen(databaseHelper: _databaseHelper),
              ),
            ),
          ),
        ],
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: _isLoading 
              ? const LinearProgressIndicator() 
              : const SizedBox.shrink(),
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildDashboard(),
          _buildBirthdaysList(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.list),
            label: 'Birthdays',
          ),
        ],
      ),
      floatingActionButton: ExpandableFab(
        distance: 112,
        children: [
          ActionButton(
            onPressed: _addBirthday,
            icon: const Icon(Icons.person_add),
            tooltip: 'Add Birthday',
          ),
          ActionButton(
            onPressed: () => _importContacts(context),
            icon: const Icon(Icons.contact_phone),
            tooltip: 'Import from Contacts',
          ),
          ActionButton(
            onPressed: () => _showBirthdayStats(context),
            icon: const Icon(Icons.analytics),
            tooltip: 'View Statistics',
          ),
        ],
      ),
    );
  }

  Future<void> _addBirthday() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddBirthdayScreen()),
    );
    if (result == true) {
      _loadBirthdays();
    }
  }

  Future<void> _editBirthday(Birthday birthday) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditBirthdayScreen(birthday: birthday),
      ),
    );
    if (result == true) {
      _loadBirthdays();
    }
  }

  Future<void> _deleteBirthday(Birthday birthday) async {
    try {
      await _databaseHelper.deleteBirthday(birthday.id!);
      _loadBirthdays();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Birthday deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting birthday: $e')),
        );
      }
    }
  }

  Future<void> _importContacts(BuildContext context) async {
    final viewModel = ContactImportViewModel(
      databaseHelper: _databaseHelper,
      onImportComplete: _loadBirthdays,
    );

    ContextService.showLoading();

    try {
      final result = await viewModel.importContacts();
      
      if (!mounted) return;
      
      ContextService.hideLoading();
      ContextService.showMessage(result);
      
    } catch (e) {
      if (!mounted) return;
      
      ContextService.hideLoading();
      ContextService.showMessage('Import failed: $e');
    }
  }

  void _showBirthdayStats(BuildContext context) {
    final averageAge = _calculateAverageAge();
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Birthday Statistics',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.cake),
              title: const Text('Average Age'),
              trailing: Text(averageAge),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Total Birthdays'),
              trailing: Text('${_birthdays.length}'),
            ),
          ],
        ),
      ),
    );
  }

  void _filterBirthdays(String query) {
    // Implement the search logic here
  }
}