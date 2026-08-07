import 'package:app_laundry/Screens/detailLaporanKas.dart';
import 'package:app_laundry/Screens/detailLaporanLayanan.dart';
import 'package:app_laundry/Screens/detailLaporanPelanggan.dart';
import 'package:app_laundry/Screens/detailLaporanPesanan.dart';
import 'package:app_laundry/Screens/mutasiKas.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Jalankan 'flutter pub add intl' jika belum ada untuk format tanggal

class CustomDateRangeDialogKas extends StatefulWidget {
  final String store_id;
  final Function(DateTimeRange) onSubmit;

  const CustomDateRangeDialogKas({super.key, required this.onSubmit, required this.store_id});

  @override
  State<CustomDateRangeDialogKas> createState() => _CustomDateRangeDialogKasState();
}

class _CustomDateRangeDialogKasState extends State<CustomDateRangeDialogKas> {
  DateTimeRange? _selectedDateRange;

  // Fungsi untuk memicu Date Range Picker bawaan Flutter dengan style kustom
  Future<void> _pickDateRange(BuildContext context) async {
    final DateTimeRange? initialRange = _selectedDateRange ??
        DateTimeRange(
          start: DateTime.now().subtract(const Duration(days: 7)),
          end: DateTime.now(),
        );

    final DateTimeRange? pickedRange = await showDateRangePicker(
      context: context,
      initialDateRange: initialRange,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      helpText: 'PILIH PERIODE LAYANAN',
      cancelText: 'BATAL',
      confirmText: 'PILIH',
      saveText: 'SIMPAN',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            // 1. Set the main scaffold background to dark grey
            scaffoldBackgroundColor: Colors.grey[900],
            
            colorScheme: ColorScheme.dark(
              brightness: Brightness.dark,
              primary: Colors.amber,              // Color of selected range circle/bar
              onPrimary: Colors.black,            // Text color inside selected range
              surface: Colors.grey[900]!,         // Background color of the calendar sheet
              onSurface: Colors.white,            // Default color for active elements
            ),

            // 2. Explicitly force all typography/text to be white
            textTheme: const TextTheme(
              bodyMedium: TextStyle(color: Colors.white),  // Calendar dates (1, 2, 3...)
              titleMedium: TextStyle(color: Colors.white), // Month headers (June 2026, July 2026)
              labelLarge: TextStyle(color: Colors.white),  // Weekdays header (S, M, T, W...)
            ),

            // 3. Keep top app bar header and icons white
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.grey[900],
              iconTheme: const IconThemeData(color: Colors.white),
              actionsIconTheme: const IconThemeData(color: Colors.white),
              titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
            ),
            
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.amberAccent),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedRange != null) {
      setState(() {
        _selectedDateRange = pickedRange;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Format tanggal Indonesia (Contoh: 12 Jun 2026)
    final dateFormat = DateFormat('dd MMM yyyy');

    return Dialog(
      backgroundColor: Colors.grey[850],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Agar tinggi dialog menyesuaikan konten
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Judul Dialog
            const Text(
              "Pilih Periode Waktu",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Box Preview Tanggal yang bisa diklik
            InkWell(
              onTap: () => _pickDateRange(context),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.amberAccent.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[900],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.date_range, color: Colors.amberAccent),
                    const SizedBox(width: 12),
                    if (_selectedDateRange == null)
                      const Text(
                        "Ketuk untuk memilih tanggal",
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      )
                    else
                      Flexible(
                        child: Text(
                          "${dateFormat.format(_selectedDateRange!.start)}   s/d   ${dateFormat.format(_selectedDateRange!.end)}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Tombol Aksi (Batal & Submit)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Batal", style: TextStyle(color: Colors.grey)),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _selectedDateRange == null
                      ? null // Button dinonaktifkan jika belum pilih tanggal
                      : () {
                          Navigator.push(context, MaterialPageRoute(builder: (contex) => DetailLaporanKasScreen(date: _selectedDateRange!, store_id: widget.store_id,)));
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amberAccent,
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: Colors.grey[700],
                  ),
                  child: const Text("Submit", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class CustomDateRangeDialogPesanan extends StatefulWidget {
  final Function(DateTimeRange) onSubmit;
  final String store_id;

  const CustomDateRangeDialogPesanan({super.key, required this.onSubmit, required this.store_id});

  @override
  State<CustomDateRangeDialogPesanan> createState() => _CustomDateRangeDialogPesananState();
}

class _CustomDateRangeDialogPesananState extends State<CustomDateRangeDialogPesanan> {
  DateTimeRange? _selectedDateRange;

  // Fungsi untuk memicu Date Range Picker bawaan Flutter dengan style kustom
  Future<void> _pickDateRange(BuildContext context) async {
    final DateTimeRange? initialRange = _selectedDateRange ??
        DateTimeRange(
          start: DateTime.now().subtract(const Duration(days: 7)),
          end: DateTime.now(),
        );

    final DateTimeRange? pickedRange = await showDateRangePicker(
      context: context,
      initialDateRange: initialRange,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      helpText: 'PILIH PERIODE LAYANAN',
      cancelText: 'BATAL',
      confirmText: 'PILIH',
      saveText: 'SIMPAN',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            // 1. Set the main scaffold background to dark grey
            scaffoldBackgroundColor: Colors.grey[900],
            
            colorScheme: ColorScheme.dark(
              brightness: Brightness.dark,
              primary: Colors.amber,              // Color of selected range circle/bar
              onPrimary: Colors.black,            // Text color inside selected range
              surface: Colors.grey[900]!,         // Background color of the calendar sheet
              onSurface: Colors.white,            // Default color for active elements
            ),

            // 2. Explicitly force all typography/text to be white
            textTheme: const TextTheme(
              bodyMedium: TextStyle(color: Colors.white),  // Calendar dates (1, 2, 3...)
              titleMedium: TextStyle(color: Colors.white), // Month headers (June 2026, July 2026)
              labelLarge: TextStyle(color: Colors.white),  // Weekdays header (S, M, T, W...)
            ),

            // 3. Keep top app bar header and icons white
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.grey[900],
              iconTheme: const IconThemeData(color: Colors.white),
              actionsIconTheme: const IconThemeData(color: Colors.white),
              titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
            ),
            
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.amberAccent),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedRange != null) {
      setState(() {
        _selectedDateRange = pickedRange;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Format tanggal Indonesia (Contoh: 12 Jun 2026)
    final dateFormat = DateFormat('dd MMM yyyy');

    return Dialog(
      backgroundColor: Colors.grey[850],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Agar tinggi dialog menyesuaikan konten
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Judul Dialog
            const Text(
              "Pilih Periode Waktu",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Box Preview Tanggal yang bisa diklik
            InkWell(
              onTap: () => _pickDateRange(context),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.amberAccent.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[900],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.date_range, color: Colors.amberAccent),
                    const SizedBox(width: 12),
                    if (_selectedDateRange == null)
                      const Text(
                        "Ketuk untuk memilih tanggal",
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      )
                    else
                      Flexible(
                        child: Text(
                          "${dateFormat.format(_selectedDateRange!.start)}   s/d   ${dateFormat.format(_selectedDateRange!.end)}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Tombol Aksi (Batal & Submit)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Batal", style: TextStyle(color: Colors.grey)),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _selectedDateRange == null
                      ? null // Button dinonaktifkan jika belum pilih tanggal
                      : () {
                          Navigator.push(context, MaterialPageRoute(builder: (contex) => DetailLaporanPesananScreen(date: _selectedDateRange!, store_id: widget.store_id,)));
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amberAccent,
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: Colors.grey[700],
                  ),
                  child: const Text("Submit", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class CustomDateRangeDialogPelanggan extends StatefulWidget {
  final Function(DateTimeRange) onSubmit;
  final String store_id;

  const CustomDateRangeDialogPelanggan({super.key, required this.onSubmit, required this.store_id});

  @override
  State<CustomDateRangeDialogPelanggan> createState() => _CustomDateRangeDialogPelangganState();
}

class _CustomDateRangeDialogPelangganState extends State<CustomDateRangeDialogPelanggan> {
  DateTimeRange? _selectedDateRange;

  // Fungsi untuk memicu Date Range Picker bawaan Flutter dengan style kustom
  Future<void> _pickDateRange(BuildContext context) async {
    final DateTimeRange? initialRange = _selectedDateRange ??
        DateTimeRange(
          start: DateTime.now().subtract(const Duration(days: 7)),
          end: DateTime.now(),
        );

    final DateTimeRange? pickedRange = await showDateRangePicker(
      context: context,
      initialDateRange: initialRange,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      helpText: 'PILIH PERIODE LAYANAN',
      cancelText: 'BATAL',
      confirmText: 'PILIH',
      saveText: 'SIMPAN',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            // 1. Set the main scaffold background to dark grey
            scaffoldBackgroundColor: Colors.grey[900],
            
            colorScheme: ColorScheme.dark(
              brightness: Brightness.dark,
              primary: Colors.amber,              // Color of selected range circle/bar
              onPrimary: Colors.black,            // Text color inside selected range
              surface: Colors.grey[900]!,         // Background color of the calendar sheet
              onSurface: Colors.white,            // Default color for active elements
            ),

            // 2. Explicitly force all typography/text to be white
            textTheme: const TextTheme(
              bodyMedium: TextStyle(color: Colors.white),  // Calendar dates (1, 2, 3...)
              titleMedium: TextStyle(color: Colors.white), // Month headers (June 2026, July 2026)
              labelLarge: TextStyle(color: Colors.white),  // Weekdays header (S, M, T, W...)
            ),

            // 3. Keep top app bar header and icons white
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.grey[900],
              iconTheme: const IconThemeData(color: Colors.white),
              actionsIconTheme: const IconThemeData(color: Colors.white),
              titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
            ),
            
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.amberAccent),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedRange != null) {
      setState(() {
        _selectedDateRange = pickedRange;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Format tanggal Indonesia (Contoh: 12 Jun 2026)
    final dateFormat = DateFormat('dd MMM yyyy');

    return Dialog(
      backgroundColor: Colors.grey[850],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Agar tinggi dialog menyesuaikan konten
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Judul Dialog
            const Text(
              "Pilih Periode Waktu",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Box Preview Tanggal yang bisa diklik
            InkWell(
              onTap: () => _pickDateRange(context),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.amberAccent.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[900],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.date_range, color: Colors.amberAccent),
                    const SizedBox(width: 12),
                    if (_selectedDateRange == null)
                      const Text(
                        "Ketuk untuk memilih tanggal",
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      )
                    else
                      Flexible(
                        child: Text(
                          "${dateFormat.format(_selectedDateRange!.start)}   s/d   ${dateFormat.format(_selectedDateRange!.end)}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Tombol Aksi (Batal & Submit)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Batal", style: TextStyle(color: Colors.grey)),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _selectedDateRange == null
                      ? null // Button dinonaktifkan jika belum pilih tanggal
                      : () {
                          Navigator.push(context, MaterialPageRoute(builder: (contex) => DetailLaporanPelangganScreen(date: _selectedDateRange!, store_id: widget.store_id,)));
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amberAccent,
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: Colors.grey[700],
                  ),
                  child: const Text("Submit", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
class CustomDateRangeDialogLayanan extends StatefulWidget {
  final Function(DateTimeRange) onSubmit;
  final String store_id;

  const CustomDateRangeDialogLayanan({super.key, required this.onSubmit, required this.store_id});

  @override
  State<CustomDateRangeDialogLayanan> createState() => _CustomDateRangeDialogLayananState();
}

class _CustomDateRangeDialogLayananState extends State<CustomDateRangeDialogLayanan> {
  DateTimeRange? _selectedDateRange;

  // Fungsi untuk memicu Date Range Picker bawaan Flutter dengan style kustom
  Future<void> _pickDateRange(BuildContext context) async {
    final DateTimeRange? initialRange = _selectedDateRange ??
        DateTimeRange(
          start: DateTime.now().subtract(const Duration(days: 7)),
          end: DateTime.now(),
        );

    final DateTimeRange? pickedRange = await showDateRangePicker(
      context: context,
      initialDateRange: initialRange,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      helpText: 'PILIH PERIODE LAYANAN',
      cancelText: 'BATAL',
      confirmText: 'PILIH',
      saveText: 'SIMPAN',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            // 1. Set the main scaffold background to dark grey
            scaffoldBackgroundColor: Colors.grey[900],
            
            colorScheme: ColorScheme.dark(
              brightness: Brightness.dark,
              primary: Colors.amber,              // Color of selected range circle/bar
              onPrimary: Colors.black,            // Text color inside selected range
              surface: Colors.grey[900]!,         // Background color of the calendar sheet
              onSurface: Colors.white,            // Default color for active elements
            ),

            // 2. Explicitly force all typography/text to be white
            textTheme: const TextTheme(
              bodyMedium: TextStyle(color: Colors.white),  // Calendar dates (1, 2, 3...)
              titleMedium: TextStyle(color: Colors.white), // Month headers (June 2026, July 2026)
              labelLarge: TextStyle(color: Colors.white),  // Weekdays header (S, M, T, W...)
            ),

            // 3. Keep top app bar header and icons white
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.grey[900],
              iconTheme: const IconThemeData(color: Colors.white),
              actionsIconTheme: const IconThemeData(color: Colors.white),
              titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
            ),
            
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.amberAccent),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedRange != null) {
      setState(() {
        _selectedDateRange = pickedRange;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Format tanggal Indonesia (Contoh: 12 Jun 2026)
    final dateFormat = DateFormat('dd MMM yyyy');

    return Dialog(
      backgroundColor: Colors.grey[850],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Agar tinggi dialog menyesuaikan konten
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Judul Dialog
            const Text(
              "Pilih Periode Waktu",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Box Preview Tanggal yang bisa diklik
            InkWell(
              onTap: () => _pickDateRange(context),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.amberAccent.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[900],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.date_range, color: Colors.amberAccent),
                    const SizedBox(width: 12),
                    if (_selectedDateRange == null)
                      const Text(
                        "Ketuk untuk memilih tanggal",
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      )
                    else
                      Flexible(
                        child: Text(
                          "${dateFormat.format(_selectedDateRange!.start)}   s/d   ${dateFormat.format(_selectedDateRange!.end)}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Tombol Aksi (Batal & Submit)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Batal", style: TextStyle(color: Colors.grey)),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _selectedDateRange == null
                      ? null // Button dinonaktifkan jika belum pilih tanggal
                      : () {
                          Navigator.push(context, MaterialPageRoute(builder: (contex) => DetailLaporanLayananScreen(date: _selectedDateRange!, store_id: widget.store_id)));
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amberAccent,
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: Colors.grey[700],
                  ),
                  child: const Text("Submit", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class CustomDateRangeDialogMutasi extends StatefulWidget {
  final String store_id;
  final Function(DateTimeRange) onSubmit;

  const CustomDateRangeDialogMutasi({super.key, required this.onSubmit, required this.store_id});

  @override
  State<CustomDateRangeDialogMutasi> createState() => _CustomDateRangeDialogMutasiState();
}

class _CustomDateRangeDialogMutasiState extends State<CustomDateRangeDialogMutasi> {
  DateTimeRange? _selectedDateRange;

  // Fungsi untuk memicu Date Range Picker bawaan Flutter dengan style kustom
  Future<void> _pickDateRange(BuildContext context) async {
    final DateTimeRange? initialRange = _selectedDateRange ??
        DateTimeRange(
          start: DateTime.now().subtract(const Duration(days: 7)),
          end: DateTime.now(),
        );

    final DateTimeRange? pickedRange = await showDateRangePicker(
      context: context,
      initialDateRange: initialRange,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      helpText: 'PILIH PERIODE LAYANAN',
      cancelText: 'BATAL',
      confirmText: 'PILIH',
      saveText: 'SIMPAN',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            // 1. Set the main scaffold background to dark grey
            scaffoldBackgroundColor: Colors.grey[900],
            
            colorScheme: ColorScheme.dark(
              brightness: Brightness.dark,
              primary: Colors.amber,              // Color of selected range circle/bar
              onPrimary: Colors.black,            // Text color inside selected range
              surface: Colors.grey[900]!,         // Background color of the calendar sheet
              onSurface: Colors.white,            // Default color for active elements
            ),

            // 2. Explicitly force all typography/text to be white
            textTheme: const TextTheme(
              bodyMedium: TextStyle(color: Colors.white),  // Calendar dates (1, 2, 3...)
              titleMedium: TextStyle(color: Colors.white), // Month headers (June 2026, July 2026)
              labelLarge: TextStyle(color: Colors.white),  // Weekdays header (S, M, T, W...)
            ),

            // 3. Keep top app bar header and icons white
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.grey[900],
              iconTheme: const IconThemeData(color: Colors.white),
              actionsIconTheme: const IconThemeData(color: Colors.white),
              titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
            ),
            
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.amberAccent),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedRange != null) {
      setState(() {
        _selectedDateRange = pickedRange;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Format tanggal Indonesia (Contoh: 12 Jun 2026)
    final dateFormat = DateFormat('dd MMM yyyy');

    return Dialog(
      backgroundColor: Colors.grey[850],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Agar tinggi dialog menyesuaikan konten
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Judul Dialog
            const Text(
              "Pilih Periode Waktu",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Box Preview Tanggal yang bisa diklik
            InkWell(
              onTap: () => _pickDateRange(context),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.amberAccent.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[900],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.date_range, color: Colors.amberAccent),
                    const SizedBox(width: 12),
                    if (_selectedDateRange == null)
                      const Text(
                        "Ketuk untuk memilih tanggal",
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      )
                    else
                      Flexible(
                        child: Text(
                          "${dateFormat.format(_selectedDateRange!.start)}   s/d   ${dateFormat.format(_selectedDateRange!.end)}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Tombol Aksi (Batal & Submit)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Batal", style: TextStyle(color: Colors.grey)),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _selectedDateRange == null
                      ? null // Button dinonaktifkan jika belum pilih tanggal
                      : () {
                          Navigator.push(context, MaterialPageRoute(builder: (contex) => MutasiKasScreen(date: _selectedDateRange!, store_id: widget.store_id,)));
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amberAccent,
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: Colors.grey[700],
                  ),
                  child: const Text("Submit", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}