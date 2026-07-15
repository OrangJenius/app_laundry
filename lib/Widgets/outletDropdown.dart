// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:app_laundry/Services/profile_service.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_laundry/Services/auth_service.dart';

class OutletDropdown extends StatefulWidget {
  final String? selectedStoreId;
  final ValueChanged<String?> onChanged;

  const OutletDropdown({
    super.key,
    required this.selectedStoreId,
    required this.onChanged,
  });

  @override
  State<OutletDropdown> createState() => _OutletDropdownState();
}

class _OutletDropdownState extends State<OutletDropdown> {
  final _supabase = Supabase.instance.client;
  
  // 1. REMOVE 'late final' and make it a nullable Future
  Future<List<Map<String, dynamic>>>? _storesFuture;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    try {
      final profileService = ProfileService();    
      final authService = AuthService();
      
      final currentUserId = _supabase.auth.currentUser!.id;
      final profile = await profileService.fetchProfileWithId(currentUserId);
      final String? ownerId = profile?.owner_id;

      if (ownerId != null) {
        // 2. Set the state cleanly here
        setState(() {
          _storesFuture = authService.getOwnerStores(ownerId);
        });
      }
    } catch (e) {
      print("Error mengambil data profil/toko: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // 3. Handle the very first frame where _storesFuture is still null (fetching profile)
    if (_storesFuture == null) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        // Match the sizing of your normal loading indicator
        child: SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.grey),
        ),
      );
    }

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _storesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.grey),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text("Gagal memuat cabang toko", style: TextStyle(color: Colors.red)),
          );
        }

        final stores = snapshot.data!;
        final bool isValidSelection = stores.any((s) => s['id'] == widget.selectedStoreId);
        
        String currentSelection;

        if (isValidSelection) {
          currentSelection = widget.selectedStoreId!;
        } else {
          currentSelection = stores.first['id'] as String;
          
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.onChanged(currentSelection);
          });
        }

        return DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: currentSelection,
            dropdownColor: Colors.white,
            style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold),
            items: stores.map((store) {
              return DropdownMenuItem<String>(
                value: store['id'] as String,
                child: Text(store['store_name'] ?? 'Tanpa Nama'),
              );
            }).toList(),
            onChanged: widget.onChanged,
          ),
        );
      },
    );
  }
}