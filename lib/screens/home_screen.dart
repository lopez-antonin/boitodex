import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/car_provider.dart';
import '../widgets/car_list_item.dart';
import 'add_edit_car_screen.dart';
import '../models/car.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedBrand;
  String? _selectedShape;

  @override
  void initState() {
    super.initState();
    final provider = context.read<CarProvider>();
    _searchController.text = provider.nameQuery;
    _searchController.addListener(() {
      provider.setNameQuery(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(BuildContext context, Car car) async {
    final provider = context.read<CarProvider>();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Supprimer la voiture'),
        content: Text('Voulez-vous vraiment supprimer "${car.name}" ?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(c).pop(false), child: Text('Annuler')),
          TextButton(onPressed: () => Navigator.of(c).pop(true), child: Text('Supprimer')),
        ],
      ),
    );
    if (confirm == true) {
      await provider.deleteCar(car.id!);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Voiture supprimée')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Collection'),
        centerTitle: true,
      ),
      body: Consumer<CarProvider>(
        builder: (context, provider, _) {
          final cars = provider.cars;
          final brands = [''].followedBy(provider.availableBrands).toList();
          final shapes = [''].followedBy(provider.availableShapes).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Rechercher par nom',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedBrand,
                        items: brands.map((b) {
                          final label = (b == '') ? 'Tout' : b;
                          return DropdownMenuItem(value: b == '' ? null : b, child: Text(label));
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedBrand = value);
                          provider.setBrandFilter(value);
                        },
                        decoration: InputDecoration(
                          labelText: 'Filtrer par marque',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedShape,
                        items: shapes.map((s) {
                          final label = (s == '') ? 'Tout' : s;
                          return DropdownMenuItem(value: s == '' ? null : s, child: Text(label));
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedShape = value);
                          provider.setShapeFilter(value);
                        },
                        decoration: InputDecoration(
                          labelText: 'Filtrer par forme',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8),
              Expanded(
                child: cars.isEmpty
                    ? Center(child: Text('Aucune voiture trouvée'))
                    : ListView.separated(
                  itemCount: cars.length,
                  separatorBuilder: (_, __) => Divider(height: 1),
                  itemBuilder: (context, index) {
                    final car = cars[index];
                    return CarListItem(
                      car: car,
                      onTap: () async {
                        // open edit screen
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => AddEditCarScreen(existingCar: car),
                          ),
                        );
                      },
                      onDelete: () => _confirmDelete(context, car),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => AddEditCarScreen()),
          );
        },
        label: Text('Ajouter'),
        icon: Icon(Icons.add),
        tooltip: 'Ajouter une nouvelle voiture',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
